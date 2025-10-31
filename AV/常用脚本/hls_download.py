import argparse
from pathlib import Path
import re
import shutil
import time
import urllib.parse
import requests
import urllib
import logging


def rm_path(file_name: str) -> None:
    path = Path(file_name)
    if not path.exists():
        return

    if path.is_dir():
        shutil.rmtree(file_name)
    else:
        path.unlink()


class HlsDownload:
    __env_dir = None
    __args = None
    __save_dir = None
    __logger = None

    def main(self) -> None:
        self.__env_dir = Path(__file__).resolve().parent
        self.parse_args()

        parsed_url = urllib.parse.urlparse(self.__args.input)
        self.__save_dir = (
            self.__env_dir
            / "hls_download"
            / f"{Path(parsed_url.path).stem}_{int(time.time())}"
        )
        rm_path(self.__save_dir)
        self.__save_dir.mkdir(parents=True, exist_ok=True)

        log_path = self.__save_dir / "download.log"
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s [%(levelname)s] %(message)s",
            datefmt="%H:%M:%S",
            handlers=[
                logging.StreamHandler(),
                logging.FileHandler(log_path, encoding="utf-8"),
            ],
        )

        self.__logger = logging.getLogger("hls_downloader")

        try:
            next_time = 0
            while True:
                curr_time = time.time()
                if curr_time < next_time:
                    time.sleep(next_time - curr_time)
                else:
                    wait_time = self.download_variant(self.__args.input)
                    if wait_time == 0:
                        wait_time = 1
                    next_time = curr_time + wait_time

        except KeyboardInterrupt:
            self.__logger.info("Download interrupted by user, exiting")
        finally:
            self.__logger.info("Downloader exited cleanly")

    def parse_args(self) -> None:
        parser = argparse.ArgumentParser(description="Download HLS and save to file")
        parser.add_argument(
            "-i",
            "--input",
            help="Input HLS url",
            required=True,
        )
        self.__args = parser.parse_args()

    def request_url(self, url) -> bytes:
        self.__logger.info(f"Requesting URL: {url}...")
        start_time = time.perf_counter()
        retry_times = 0
        while True:
            try:
                response = requests.get(url)
            except Exception as e:
                if retry_times < 5:
                    retry_times += 1
                    self.__logger.warning(
                        f"Request error: {e}, next retry times={retry_times}"
                    )
                    continue

                self.__logger.error(f"Request failed after retries: {e}")
                return None
            break

        elapsed = time.perf_counter() - start_time
        if retry_times > 0:
            self.__logger.warning(
                f"Request succeeded after {retry_times} retries, time used: {elapsed:.2f}s, size: {len(response.content) / 1024:.1f} KB"
            )
        else:
            self.__logger.info(
                f"Request succeeded, time used: {elapsed:.2f}s, size: {len(response.content) / 1024:.1f} KB"
            )

        return response.content

    def download_variant(self, url) -> float:
        url_bytes = self.request_url(url)
        if not url_bytes:
            return 3
        url_content = url_bytes.decode(encoding="utf-8")

        parsed_url = urllib.parse.urlparse(url)
        save_path = self.__save_dir / f".{parsed_url.path}"
        save_path.parent.mkdir(parents=True, exist_ok=True)
        with open(save_path, "w", encoding="utf-8") as file:
            file.write(url_content)

        combined_save_path = (
            save_path.parent / f"{save_path.stem}_combined{save_path.suffix}"
        )
        combined_save_file = None

        wait_time = 0
        curr_type = ""
        curr_extinf_line = 0
        for line in url_content.splitlines():
            line = line.strip()
            if not line:
                continue

            if line.startswith("#EXT-X-STREAM-INF"):
                curr_type = "variant"
            elif line.startswith("#EXTINF"):
                curr_type = "segment"
                curr_extinf_line = line
                if not combined_save_file:
                    combined_save_file = open(combined_save_path, "a", encoding="utf-8")
            else:
                if not line.startswith("#"):
                    if curr_type == "variant":
                        variant_url = urllib.parse.urljoin(url, line)
                        variant_wait_time = self.download_variant(variant_url)
                        if wait_time == 0 or variant_wait_time < wait_time:
                            wait_time = variant_wait_time

                    elif curr_type == "segment":
                        segment_url = urllib.parse.urljoin(url, line)
                        segment_parsed_url = urllib.parse.urlparse(segment_url)
                        segment_save_path = (
                            self.__save_dir / f".{segment_parsed_url.path}"
                        )
                        if segment_save_path.exists():
                            continue

                        segment_bytes = self.request_url(segment_url)
                        if not segment_bytes:
                            continue

                        self.__logger.info(
                            f"Segment {segment_parsed_url.path} {curr_extinf_line}"
                        )
                        combined_save_file.write(f"{curr_extinf_line}\n")
                        combined_save_file.write(f"{line}\n")

                        match = re.search(r"\d+\.\d+|\d+", curr_extinf_line)
                        if match and match.group():
                            wait_time = float(match.group())

                        self.__logger.info(f"Saved segment to {segment_save_path}")
                        segment_save_path.parent.mkdir(parents=True, exist_ok=True)
                        with open(segment_save_path, "wb") as file:
                            file.write(segment_bytes)

        if combined_save_file:
            combined_save_file.close()
        return wait_time


if __name__ == "__main__":
    hls_download = HlsDownload()
    hls_download.main()

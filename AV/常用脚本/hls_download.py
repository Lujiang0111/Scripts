import argparse
from pathlib import Path
import re
import shutil
import time
import urllib.parse
import requests
import urllib


def rm_path(file_name: str) -> None:
    path = Path(file_name)
    if not path.exists():
        return

    if path.is_dir():
        shutil.rmtree(file_name)
    else:
        path.unlink()


def request_url(url) -> bytes:
    retry_times = 0
    while True:
        print(f"request url={url}...")
        try:
            response = requests.get(url)
        except Exception as e:
            if retry_times < 5:
                retry_times += 1
                print(f"request error: {e}, retry times={retry_times}")
                continue
            else:
                print(f"request error: {e}, ignore")
                return None
        break

    if retry_times > 0:
        print(f"request url={url} success, but retry times={retry_times}")

    return response.content


class HlsDownload:
    __env_dir = None
    __args = None
    __save_dir = None

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

        try:
            next_time = 0
            while True:
                curr_time = time.time()
                if curr_time < next_time:
                    time.sleep(next_time - curr_time)
                else:
                    wait_time = self.download_variant(self.__args.input)
                    if 0 == wait_time:
                        wait_time = 1
                    next_time = curr_time + wait_time

        except KeyboardInterrupt:
            print("Download interrupt, exit")
        finally:
            pass

    def parse_args(self) -> None:
        parser = argparse.ArgumentParser(description="Download Hls and save to file")
        parser.add_argument(
            "-i",
            "--input",
            help="Input Hls url",
            required=True,
        )
        self.__args = parser.parse_args()

    def download_variant(self, url) -> float:
        url_bytes = request_url(url)
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
                    if "variant" == curr_type:
                        variant_url = urllib.parse.urljoin(url, line)
                        variant_wait_time = self.download_variant(variant_url)
                        if 0 == wait_time or variant_wait_time < wait_time:
                            wait_time = variant_wait_time

                    elif "segment" == curr_type:
                        segment_url = urllib.parse.urljoin(url, line)
                        segment_parsed_url = urllib.parse.urlparse(segment_url)
                        segment_save_path = (
                            self.__save_dir / f".{segment_parsed_url.path}"
                        )
                        if segment_save_path.exists():
                            continue

                        print()
                        segment_bytes = request_url(segment_url)
                        if not segment_bytes:
                            continue

                        print(f"{curr_extinf_line}")
                        combined_save_file.write(f"{curr_extinf_line}\n")
                        combined_save_file.write(f"{line}\n")
                        match = re.search(r"\d+\.\d+|\d+", curr_extinf_line)
                        if match.group():
                            wait_time = float(match.group())

                        print(f"save to {segment_save_path}")
                        segment_save_path.parent.mkdir(parents=True, exist_ok=True)
                        with open(segment_save_path, "wb") as file:
                            file.write(segment_bytes)

        if combined_save_file:
            combined_save_file.close()
        return wait_time


if __name__ == "__main__":
    hls_download = HlsDownload()
    hls_download.main()

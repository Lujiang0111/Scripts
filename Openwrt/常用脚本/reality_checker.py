import argparse
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
import re
import shutil
import socket
import subprocess
import sys
from typing import List, Tuple
import urllib.parse

import requests

try:
    import dns.resolver
except ImportError:
    dns = None


def parse_url(url: str) -> Tuple[str, int]:
    url = url.strip()
    if "://" not in url:
        url = "//" + url
    u = urllib.parse.urlsplit(url)
    return u.hostname, u.port or 443


class ExampleClass:
    __args = None

    __host = None
    __port = None
    __timeout = None

    __openssl = None

    def main(self, args) -> None:
        self.parse_args()

        if not self.prepare_openssl():
            exit(0)

        print("\n=============== TLS ===============")
        self.check_tls1_3()
        self.check_x25519()
        self.check_http2()
        self.check_ocsp_stapling()

        print("\n=============== CDN ===============")
        self.check_cdn()

    def parse_args(self) -> None:
        parser = argparse.ArgumentParser(description="arg description")
        parser.add_argument(
            "url", help="specify host:port, example: www.nvidia.cn:443", type=str
        )
        parser.add_argument(
            "-t",
            "--timeout",
            help="timeout per probe in seconds, default: 10",
            type=int,
            default=10,
        )

        self.__args = parser.parse_args()

        self.__host, self.__port = parse_url(self.__args.url)
        self.__timeout = self.__args.timeout

    def prepare_openssl(self) -> bool:
        self.__openssl = shutil.which("openssl")
        if not self.__openssl:
            print("Error : Could not find openssl")
            return False

        return True

    def run_openssl_s_client(self, extra_args: List[str]) -> Tuple[int, str]:
        cmd = [
            self.__openssl,
            "s_client",
            "-connect",
            f"{self.__host}:{self.__port}",
            "-servername",
            self.__host,
        ]
        cmd += extra_args

        try:
            cp = subprocess.run(
                cmd,
                input=b"",
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                check=False,
                timeout=self.__timeout,
            )

            output = cp.stdout.decode("utf-8", errors="replace")
            return cp.returncode, output

        except subprocess.TimeoutExpired:
            return 124, ""

    def extract_protocol(self, output: str) -> str:
        patterns = [
            r"Protocol\s*:\s*(TLSv[0-9.]+)",
            r"Protocol version\s*:\s*(TLSv[0-9.]+)",
            r"New,\s*(TLSv[0-9.]+),",
        ]

        for p in patterns:
            m = re.search(p, output, re.IGNORECASE)
            if m:
                return m.group(1).strip()

        return None

    def check_tls1_3(self) -> None:
        returncode, output = self.run_openssl_s_client(["-tls1_3"])
        if 0 != returncode:
            print(f"Check TLS1.3: [fail], returncode={returncode}")
            return

        protocol = self.extract_protocol(output)
        if protocol and "TLSv1.3" == protocol:
            print(f"Check TLS1.3: [success], protocol={protocol}")
            return

        print(f"Check TLS1.3: [fail], protocol={protocol}")

    def extract_temp_key(self, output: str) -> str:
        patterns = [
            r"Server Temp Key\s*:\s*([^\r\n]+)",
            r"Peer Temp Key\s*:\s*([^\r\n]+)",
        ]

        for p in patterns:
            m = re.search(p, output, re.IGNORECASE)
            if m:
                return m.group(1).strip()

        return None

    def check_x25519(self) -> None:
        returncode, output = self.run_openssl_s_client(["-tls1_3", "-groups", "X25519"])
        if 0 != returncode:
            print(f"Check X25519: [fail], returncode={returncode}")
            return

        protocol = self.extract_protocol(output)
        temp_key = self.extract_temp_key(output)
        if (
            protocol
            and "TLSv1.3" == protocol
            and temp_key
            and "X25519" in temp_key.upper()
        ):
            print(f"Check X25519: [success], temp_key={temp_key}")
            return

        print(f"Check X25519: [fail], protocol={protocol}, temp_key={temp_key}")

    def extract_alpn(self, output: str) -> str:
        patterns = [
            r"ALPN protocol\s*:\s*([^\r\n]+)",
        ]

        for p in patterns:
            m = re.search(p, output, re.IGNORECASE)
            if m:
                return m.group(1).strip()

        return None

    def check_http2(self) -> None:
        returncode, output = self.run_openssl_s_client(["-alpn", "h2"])
        if 0 != returncode:
            print(f"Check HTTP/2: [fail], returncode={returncode}")
            return

        alpn = self.extract_alpn(output)
        if alpn and "h2" == alpn:
            print(f"Check HTTP/2: [success], alpn={alpn}")
            return

        print(f"Check HTTP/2: [fail], alpn={alpn}")

    def extract_ocsp(self, output: str) -> str:
        if re.search(r"OCSP response\s*:\s*no response sent", output, re.IGNORECASE):
            return None

        m = re.search(r"OCSP Response Status\s*:\s*([^\r\n]+)", output, re.IGNORECASE)
        if m:
            return m.group(1).strip()

        return None

    def check_ocsp_stapling(self) -> None:
        returncode, output = self.run_openssl_s_client(["-status"])
        if 0 != returncode:
            print(f"Check Ocsp stapling: [fail], returncode={returncode}")
            return

        ocsp = self.extract_ocsp(output)
        if ocsp and "successful" in ocsp.lower():
            print(f"Check Ocsp stapling: [success], ocsp={ocsp}")
            return

        print(f"Check Ocsp stapling: [fail], ocsp={ocsp}")

    CDN_DOMAIN_PATTERNS = {
        "Cloudflare": [
            r"cloudflare\.net$",
        ],
        "AWS CloudFront": [
            r"cloudfront\.net$",
        ],
        "Akamai": [
            r"akamai",
            r"akamaiedge\.net$",
            r"edgekey\.net$",
            r"edgesuite\.net$",
            r"akadns\.net$",
        ],
        "Fastly": [
            r"fastly\.net$",
            r"fastlylb\.net$",
            r"map\.fastly\.net$",
        ],
        "Azure CDN / Front Door": [
            r"azureedge\.net$",
            r"azurefd\.net$",
            r"azurefd\.com$",
            r"trafficmanager\.net$",
        ],
        "Google Cloud CDN / Google Frontend": [
            r"googleusercontent\.com$",
            r"googlehosted\.com$",
            r"google\.com$",
            r"1e100\.net$",
        ],
        "Alibaba Cloud CDN": [
            r"alicdn\.com$",
            r"kunluncdn\.com$",
            r"kunlunsl\.com$",
            r"alikunlun\.com$",
            r"aliyuncs\.com$",
        ],
        "Tencent Cloud CDN": [
            r"qcloudcdn\.com$",
            r"cdn\.dnsv1\.com$",
            r"dnsv1\.com$",
            r"tencent-cloud\.net$",
        ],
        "Baidu CDN": [
            r"bdydns\.com$",
            r"bdstatic\.com$",
            r"baidubce\.com$",
        ],
        "Wangsu / CDNetworks": [
            r"wscdns\.com$",
            r"wscloudcdn\.com$",
            r"cdnetworks\.net$",
            r"gccdn\.net$",
            r"lxdns\.com$",
        ],
        "ChinaCache": [
            r"chinacache\.net$",
            r"ccgslb\.com$",
        ],
        "BunnyCDN": [
            r"b-cdn\.net$",
            r"bunnycdn\.com$",
        ],
        "KeyCDN": [
            r"kxcdn\.com$",
            r"keycdn\.com$",
        ],
        "Imperva / Incapsula": [
            r"impervadns\.net$",
            r"incapdns\.net$",
        ],
        "Sucuri": [
            r"sucuri\.net$",
        ],
        "StackPath / NetDNA": [
            r"stackpathdns\.com$",
            r"hwcdn\.net$",
            r"netdna-cdn\.com$",
        ],
    }

    HEADER_RULES = [
        # provider, weight, header_name_regex, header_value_regex, description
        ("Cloudflare", 5, r"^cf-ray$", r".+", "Cloudflare 特征响应头 cf-ray"),
        (
            "Cloudflare",
            5,
            r"^cf-cache-status$",
            r".+",
            "Cloudflare 缓存状态头 cf-cache-status",
        ),
        ("Cloudflare", 4, r"^cf-apo-via$", r".+", "Cloudflare APO 特征头"),
        ("Cloudflare", 4, r"^server$", r"cloudflare", "Server 显示 cloudflare"),
        ("AWS CloudFront", 5, r"^x-amz-cf-id$", r".+", "CloudFront 特征头 x-amz-cf-id"),
        (
            "AWS CloudFront",
            5,
            r"^x-amz-cf-pop$",
            r".+",
            "CloudFront POP 特征头 x-amz-cf-pop",
        ),
        ("AWS CloudFront", 5, r"^x-cache$", r"cloudfront", "X-Cache 显示 cloudfront"),
        ("AWS CloudFront", 4, r"^via$", r"cloudfront", "Via 中出现 cloudfront"),
        (
            "AWS CloudFront",
            3,
            r"^server-timing$",
            r"cdn-cache-|cdn-pop",
            "Server-Timing 出现 CDN 缓存/POP 指标",
        ),
        ("Fastly", 5, r"^x-served-by$", r"cache-|fastly", "Fastly 常见 x-served-by"),
        ("Fastly", 4, r"^x-timer$", r".+", "Fastly 常见 x-timer"),
        ("Fastly", 4, r"^x-cache-hits$", r".+", "Fastly/Varnish 缓存命中次数头"),
        ("Fastly", 4, r"^fastly-", r".+", "Fastly 专有响应头"),
        ("Fastly", 3, r"^server$", r"fastly", "Server 显示 fastly"),
        ("Akamai", 5, r"^akamai-", r".+", "Akamai 特征响应头"),
        ("Akamai", 5, r"^x-akamai-", r".+", "Akamai 特征响应头"),
        ("Akamai", 5, r"^akamai-grn$", r".+", "Akamai GRN 特征头"),
        ("Akamai", 4, r"^server$", r"akamaighost", "Server 显示 AkamaiGHost"),
        (
            "Azure CDN / Front Door",
            5,
            r"^x-azure-ref$",
            r".+",
            "Azure Front Door/CDN 特征头",
        ),
        ("Azure CDN / Front Door", 4, r"^x-cache$", r"azure", "X-Cache 出现 Azure"),
        (
            "Azure CDN / Front Door",
            4,
            r"^server$",
            r"azure|microsoft",
            "Server 出现 Azure/Microsoft 线索",
        ),
        ("Alibaba Cloud CDN", 5, r"^x-swift-", r".+", "阿里云 CDN 常见 x-swift-*"),
        (
            "Alibaba Cloud CDN",
            4,
            r"^x-cache$",
            r"alicdn|kunlun|tengine",
            "X-Cache 出现阿里云 CDN 线索",
        ),
        (
            "Alibaba Cloud CDN",
            3,
            r"^server$",
            r"tengine",
            "Server 显示 Tengine，可能是阿里云/淘宝系网关",
        ),
        (
            "Tencent Cloud CDN",
            5,
            r"^x-cache-lookup$",
            r".+",
            "腾讯云 CDN 常见 x-cache-lookup",
        ),
        ("Tencent Cloud CDN", 4, r"^x-cdn-src-port$", r".+", "腾讯云 CDN 相关头"),
        ("Tencent Cloud CDN", 4, r"^server$", r"tencent|stgw", "Server 出现腾讯云线索"),
        ("Baidu CDN", 5, r"^x-bdcdn-", r".+", "百度 CDN 特征响应头"),
        ("Baidu CDN", 4, r"^server$", r"bfe", "Server 显示 BFE，可能是百度边缘/网关"),
        ("BunnyCDN", 5, r"^bunnycdn-", r".+", "BunnyCDN 特征响应头"),
        ("BunnyCDN", 4, r"^server$", r"bunnycdn", "Server 显示 BunnyCDN"),
        ("KeyCDN", 5, r"^x-edge-location$", r".+", "KeyCDN 常见边缘位置头"),
        ("KeyCDN", 4, r"^server$", r"keycdn", "Server 显示 KeyCDN"),
        (
            "Imperva / Incapsula",
            5,
            r"^incap_ses|^visid_incap",
            r".+",
            "Imperva/Incapsula Cookie 或响应头",
        ),
        ("Imperva / Incapsula", 4, r"^x-iinfo$", r".+", "Imperva/Incapsula 特征头"),
        ("Sucuri", 5, r"^x-sucuri-", r".+", "Sucuri 特征响应头"),
        ("Sucuri", 4, r"^server$", r"sucuri", "Server 显示 Sucuri"),
        ("StackPath / NetDNA", 5, r"^x-hw$", r".+", "StackPath/Highwinds 特征头"),
        (
            "StackPath / NetDNA",
            4,
            r"^server$",
            r"stackpath|netdna",
            "Server 显示 StackPath/NetDNA",
        ),
        # 通用缓存/代理线索，不能单独强判具体 CDN
        (
            "Generic CDN/cache proxy",
            2,
            r"^cache-status$",
            r".+",
            "通用 Cache-Status 头",
        ),
        (
            "Generic CDN/cache proxy",
            2,
            r"^x-cache$",
            r"hit|miss|cache|refresh",
            "通用 X-Cache 头",
        ),
        (
            "Generic CDN/cache proxy",
            1,
            r"^age$",
            r"^\d+$",
            "Age 头，说明可能来自缓存层",
        ),
        ("Generic CDN/cache proxy", 1, r"^via$", r".+", "Via 头，说明经过代理/缓存层"),
    ]

    def normalize_target(self, target: str) -> tuple[str, str]:
        if not target.startswith(("http://", "https://")):
            target = "https://" + target

        parsed = urllib.parse.urlparse(target)
        if not parsed.hostname:
            raise ValueError("无法解析目标域名")

        host = parsed.hostname.strip(".")
        return target, host

    def get_cname_chain(self, host: str, timeout: float = 3.0) -> list[str]:
        if dns is None:
            return []

        chain = []
        seen = set()
        current = host

        resolver = dns.resolver.Resolver()
        resolver.lifetime = timeout
        resolver.timeout = timeout

        for _ in range(10):
            if current in seen:
                break
            seen.add(current)

            try:
                answers = resolver.resolve(current, "CNAME")
            except Exception:
                break

            if not answers:
                break

            cname = str(answers[0].target).rstrip(".")
            chain.append(cname)
            current = cname

        return chain

    def resolve_ips(self, host: str) -> list[str]:
        ips = set()
        try:
            for item in socket.getaddrinfo(host, None):
                ip = item[4][0]
                ips.add(ip)
        except Exception:
            pass

        return sorted(ips)

    def reverse_dns_lookup(self, ip: str) -> str | None:
        try:
            return socket.gethostbyaddr(ip)[0].rstrip(".")
        except Exception:
            return None

    def reverse_dns_all(
        self, ips: list[str], max_workers: int = 8, timeout: float = 4.0
    ) -> dict[str, str]:
        if not ips:
            return {}

        results = {}
        with ThreadPoolExecutor(max_workers=min(max_workers, len(ips))) as pool:
            futures = {pool.submit(self.reverse_dns_lookup, ip): ip for ip in ips}

            try:
                for future in as_completed(futures, timeout=timeout):
                    ip = futures[future]
                    ptr = future.result()
                    if ptr:
                        results[ip] = ptr
            except Exception:
                pass

        return results

    def fetch_headers(
        self, url: str, timeout: float = 8.0, insecure: bool = False
    ) -> tuple[int | None, str, dict[str, str], str | None]:
        session = requests.Session()
        headers = {
            "User-Agent": "cdn-detect/1.0 (+https://example.local)",
            "Accept": "*/*",
        }

        verify = not insecure

        try:
            resp = session.head(
                url,
                allow_redirects=True,
                timeout=timeout,
                headers=headers,
                verify=verify,
            )

            # 有些站点不支持 HEAD，改用 GET
            if resp.status_code in (405, 501) or not resp.headers:
                resp = session.get(
                    url,
                    allow_redirects=True,
                    timeout=timeout,
                    headers=headers,
                    verify=verify,
                    stream=True,
                )

            return resp.status_code, resp.url, dict(resp.headers), None

        except Exception as e:
            return None, url, {}, str(e)

    def match_domain_patterns(self, text: str) -> list[tuple[str, int, str]]:
        evidence = []
        value = text.lower().rstrip(".")

        for provider, patterns in self.CDN_DOMAIN_PATTERNS.items():
            for pattern in patterns:
                if re.search(pattern, value, re.I):
                    evidence.append(
                        (provider, 5, f"DNS/反向解析命中 {provider} 域名特征: {text}")
                    )
                    break

        return evidence

    def match_header_rules(self, headers: dict[str, str]) -> list[tuple[str, int, str]]:
        evidence = []

        for name, value in headers.items():
            header_name = name.lower().strip()
            header_value = str(value).strip()

            for provider, weight, name_re, value_re, desc in self.HEADER_RULES:
                if re.search(name_re, header_name, re.I) and re.search(
                    value_re, header_value, re.I
                ):
                    evidence.append(
                        (
                            provider,
                            weight,
                            f"HTTP Header 命中: {name}: {header_value} ({desc})",
                        )
                    )

        return evidence

    def classify(
        self, scores: dict[str, int]
    ) -> tuple[bool, str, list[tuple[str, int]]]:
        sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)

        specific_scores = [
            item for item in sorted_scores if item[0] != "Generic CDN/cache proxy"
        ]

        top_specific_score = specific_scores[0][1] if specific_scores else 0
        generic_score = scores.get("Generic CDN/cache proxy", 0)

        if top_specific_score >= 8:
            return True, "high", sorted_scores
        if top_specific_score >= 5:
            return True, "medium", sorted_scores
        if top_specific_score >= 3 or generic_score >= 4:
            return True, "low", sorted_scores

        return False, "none", sorted_scores

    def detect_cdn(
        self, target: str, timeout: float, insecure: bool, enable_rdns: bool
    ) -> dict:
        url, host = self.normalize_target(target)

        evidence = []
        scores = defaultdict(int)

        cname_chain = self.get_cname_chain(host, timeout=timeout)
        ips = self.resolve_ips(host)

        for cname in cname_chain:
            for provider, weight, desc in self.match_domain_patterns(cname):
                scores[provider] += weight
                evidence.append(
                    {
                        "provider": provider,
                        "weight": weight,
                        "source": "dns_cname",
                        "detail": desc,
                    }
                )

        rdns = {}
        if enable_rdns:
            rdns = self.reverse_dns_all(ips, timeout=timeout)
            for ip, ptr in rdns.items():
                for provider, weight, desc in self.match_domain_patterns(ptr):
                    # rDNS 可信度略低一点
                    weight = max(2, weight - 2)
                    scores[provider] += weight
                    evidence.append(
                        {
                            "provider": provider,
                            "weight": weight,
                            "source": "reverse_dns",
                            "detail": f"{ip} -> {ptr}; {desc}",
                        }
                    )

        status_code, final_url, headers, error = self.fetch_headers(
            url,
            timeout=timeout,
            insecure=insecure,
        )

        for provider, weight, desc in self.match_header_rules(headers):
            scores[provider] += weight
            evidence.append(
                {
                    "provider": provider,
                    "weight": weight,
                    "source": "http_header",
                    "detail": desc,
                }
            )

        uses_cdn, confidence, ranked = self.classify(scores)

        return {
            "target": target,
            "normalized_url": url,
            "final_url": final_url,
            "host": host,
            "http_status": status_code,
            "http_error": error,
            "uses_cdn": uses_cdn,
            "confidence": confidence,
            "providers": [
                {"name": name, "score": score} for name, score in ranked if score > 0
            ],
            "ips": ips,
            "cname_chain": cname_chain,
            "reverse_dns": rdns,
            "evidence": sorted(evidence, key=lambda x: x["weight"], reverse=True),
            "headers_sample": {
                k: v
                for k, v in headers.items()
                if re.search(
                    r"cdn|cache|cf-|cloudfront|akamai|fastly|azure|x-amz-cf|x-served-by|x-cache|via|age|server|sucuri|incap|bunny|edge",
                    k,
                    re.I,
                )
            },
        }

    def check_cdn(self) -> None:
        result = self.detect_cdn(
            target=self.__host,
            timeout=self.__timeout,
            insecure=False,
            enable_rdns=False,
        )

        print(f"目标: {result['target']}")
        print(f"Host: {result['host']}")
        print(f"最终 URL: {result['final_url']}")
        print(f"HTTP 状态码: {result['http_status']}")

        if result["http_error"]:
            print(f"HTTP 请求错误: {result['http_error']}")

        print("-" * 70)

        if result["uses_cdn"]:
            print("结论: 疑似使用 CDN")
            print(f"可信度: {result['confidence']}")
        else:
            print("结论: 未发现明确 CDN 特征")
            print("可信度: none")

        if result["providers"]:
            print("\n疑似厂商/类型:")
            for item in result["providers"]:
                print(f"  - {item['name']}: score={item['score']}")

        print("\nDNS CNAME 链:")
        if result["cname_chain"]:
            for cname in result["cname_chain"]:
                print(f"  - {cname}")
        else:
            print("  - 未发现 CNAME，或未安装 dnspython / DNS 无 CNAME")

        print("\n解析 IP:")
        if result["ips"]:
            for ip in result["ips"]:
                ptr = result["reverse_dns"].get(ip)
                if ptr:
                    print(f"  - {ip} -> {ptr}")
                else:
                    print(f"  - {ip}")
        else:
            print("  - 未解析到 IP")

        print("\n证据:")
        if result["evidence"]:
            for ev in result["evidence"]:
                print(
                    f"  - [{ev['source']}] {ev['provider']} +{ev['weight']}: {ev['detail']}"
                )
        else:
            print("  - 无明确证据")

        print("\n相关响应头样本:")
        if result["headers_sample"]:
            for k, v in result["headers_sample"].items():
                print(f"  - {k}: {v}")
        else:
            print("  - 未发现明显 CDN/cache 相关响应头")


if __name__ == "__main__":
    h = ExampleClass()
    h.main(sys.argv)

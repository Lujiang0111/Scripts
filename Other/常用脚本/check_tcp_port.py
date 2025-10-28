import socket
import argparse


def check_tcp_port(ip, port, timeout=3):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(timeout)
        try:
            sock.connect((ip, port))
            return True
        except (socket.timeout, socket.error):
            return False


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Check if a TCP port is open on a given IP."
    )
    parser.add_argument("ip", help="IP address to check")
    parser.add_argument("port", type=int, help="TCP port to check")
    args = parser.parse_args()

    if check_tcp_port(args.ip, args.port):
        print(f"{args.ip}:{args.port} is open.")
    else:
        print(f"{args.ip}:{args.port} is closed or unreachable.")

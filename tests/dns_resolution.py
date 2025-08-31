#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#     "pyyaml"
# ]
# ///
import yaml
import socket
import sys
from pathlib import Path

GREEN = "\033[92m"
RED = "\033[91m"
ORANGE = "\033[93m"
RESET = "\033[0m"


def is_tailscale_ip(ip: str) -> bool:
    return ip.startswith("100.")


def main() -> int:
    yml_path = Path(__file__).parent.parent / "hosts.yml"
    has_red = False
    with open(yml_path) as ymlfile:
        hosts = yaml.safe_load(ymlfile)
        for name, details in hosts.items():
            expected_ip = details.get("ip")
            if not expected_ip:
                continue
            try:
                resolved_ip = socket.gethostbyname(name)
                if resolved_ip == expected_ip:
                    print(f"{name:15} {GREEN}OK{RESET} ({resolved_ip})")
                elif is_tailscale_ip(resolved_ip):
                    print(
                        f"{name:15} {ORANGE}TAILSCALE IP{RESET} (got {resolved_ip}, expected {expected_ip})"
                    )
                else:
                    print(
                        f"{name:15} {RED}WRONG IP{RESET} (got {resolved_ip}, expected {expected_ip})"
                    )
                    has_red = True
            except socket.gaierror:
                print(f"{name:15} {RED}NOT RESOLVED{RESET}")
                has_red = True
    return 1 if has_red else 0


if __name__ == "__main__":
    sys.exit(main())

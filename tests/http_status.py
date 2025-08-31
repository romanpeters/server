#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#     "requests",
#     "pyyaml"
# ]
# ///
import yaml
import sys
from pathlib import Path

import requests

GREEN = "\033[92m"
RED = "\033[91m"
ORANGE = "\033[93m"
RESET = "\033[0m"

domain_name = "romanpeters.nl"


def main() -> int:
    yml_path = Path(__file__).parent.parent / "services.yml"
    has_red = False
    with open(yml_path) as ymlfile:
        services = yaml.safe_load(ymlfile)
        for name, details in services.items():
            port = details.get("port")
            if not port:
                continue

            url = f"https://{name}.{domain_name}"
            try:
                response = requests.get(url, timeout=5)
                if response.status_code == 200:
                    print(
                        f"{name:15} {url:40} {GREEN}OK{RESET} [{response.status_code}]"
                    )
                else:
                    print(
                        f"{name:15} {url:40} {RED}FAIL{RESET} [{response.status_code}]"
                    )
                    has_red = True
            except requests.ConnectionError:
                print(f"{name:15} {url:40} {RED}NOT REACHABLE{RESET}")
                has_red = True
    return 1 if has_red else 0


if __name__ == "__main__":
    sys.exit(main())

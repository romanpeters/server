#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#   "pyyaml",
# ]
# ///
import yaml
import sys
from pathlib import Path
import subprocess

GREEN = "\033[92m"
RED = "\033[91m"
ORANGE = "\033[93m"
RESET = "\033[0m"


def is_reachable(ip: str) -> bool:
    try:
        subprocess.check_call(
            ["ping", "-c", "1", ip],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return True
    except subprocess.CalledProcessError:
        return False


def main() -> int:
    yml_path = Path(__file__).parent.parent / "hosts.yml"
    red_alert = False

    try:
        with open(yml_path, "r") as f:
            hosts_data = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: hosts.yml not found at {yml_path}", file=sys.stderr)
        sys.exit(1)

    for name, details in hosts_data.items():
        ip = details.get("ip")
        os_val = details.get("os")

        if not ip:
            continue

        if is_reachable(ip):
            status = GREEN + "REACHABLE" + RESET
        elif os_val == "unmanaged":
            status = ORANGE + "UNREACHABLE" + RESET
        else:
            status = RED + "UNREACHABLE" + RESET
            red_alert = True

        status_output = f"{name:15} {ip:15} {status}"
        print(status_output)

    return 1 if red_alert else 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
# ]
# ///
import csv

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
    csv_path = Path(__file__).parent.parent / "data/hosts.csv"
    red_alert = False
    with open(csv_path, newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            name = row["name"]
            ip = row["ip"]
            os = row.get("os")
            if is_reachable(ip):
                status = GREEN + "REACHABLE" + RESET
            elif os == "unmanaged":
                status = ORANGE + "UNREACHABLE" + RESET
            else:
                status = RED + "UNREACHABLE" + RESET
                red_alert = True

            status_output = f"{name:15} {ip:15} {status}"
            print(status_output)

    return 1 if red_alert else 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#   "pyyaml"
# ]
# ///

import os
import yaml
from pathlib import Path
import sys


def main():
    docker_root = Path("docker")
    if not docker_root.is_dir():
        print(
            "Error: 'docker' directory not found. Make sure the script is run from the project root.",
            file=sys.stderr,
        )
        sys.exit(1)

    compose_files = docker_root.glob("**/docker-compose.yml")

    bind_mount_dirs = set()

    for compose_file in compose_files:
        compose_dir = compose_file.parent
        with open(compose_file, "r") as f:
            try:
                data = yaml.safe_load(f)
                if not data or "services" not in data:
                    continue

                for service in data["services"].values():
                    if "volumes" not in service:
                        continue

                    for volume in service["volumes"]:
                        if isinstance(volume, str) and ":" in volume:
                            host_path = volume.split(":")[0]

                            if host_path.startswith("./"):
                                # Heuristic to check if it's a directory, not a file
                                if not Path(host_path).suffix:
                                    # Construct path relative to project root
                                    full_path = compose_dir / Path(host_path)
                                    # Normalize the path (e.g., remove './')
                                    normalized_path = os.path.normpath(str(full_path))
                                    bind_mount_dirs.add(normalized_path)

            except yaml.YAMLError as e:
                print(f"Error parsing {compose_file}: {e}", file=sys.stderr)

    for d in sorted(list(bind_mount_dirs)):
        print(d)


if __name__ == "__main__":
    main()

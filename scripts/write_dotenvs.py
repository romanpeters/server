#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
# ]
# ///
import os
import csv
import configparser


def main():
    """
    Generates .env files for docker-compose files based on services.csv.
    Correctly handles multiple services, including those with the same container value
    but different compose files, by grouping based on the compose file path.
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)

    vars_ini_path = os.path.join(project_root, "data", "vars.ini")
    services_csv_path = os.path.join(project_root, "data", "services.csv")
    docker_dir = os.path.join(project_root, "docker")

    # Read domain_name from vars.ini
    config = configparser.ConfigParser()
    config.read(vars_ini_path)
    domain_name = config.get("DEFAULT", "domain_name")

    # Maps a specific docker-compose.yml path to a list of its env var strings
    compose_env_map = {}

    with open(services_csv_path, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if not row.get("container"):
                continue

            container = row["container"]
            name = row["name"]
            port = row["port"]

            # Determine the correct path for the docker-compose.yml
            path_single = os.path.join(
                docker_dir, container, name, "docker-compose.yml"
            )
            path_group = os.path.join(docker_dir, container, "docker-compose.yml")

            compose_path = None
            path_single_exists = os.path.exists(path_single)
            path_group_exists = os.path.exists(path_group)

            if path_single_exists:
                compose_path = path_single
            elif path_group_exists:
                compose_path = path_group
            else:
                # This service doesn't seem to have a compose file, skip it.
                continue

            # Initialize the list of env vars for this compose file if it's new
            if compose_path not in compose_env_map:
                compose_env_map[compose_path] = []

            # Add the service's port variable
            compose_env_map[compose_path].append(f"{name.upper()}_PORT={port}")

    # Now, write the consolidated .env files
    for compose_path, env_vars in compose_env_map.items():
        compose_dir = os.path.dirname(compose_path)

        # Prepend the common variables
        full_env_content = [
            "# This file is auto-generated. Do not edit.",
            f"DOMAIN_NAME={domain_name}",
        ]
        full_env_content.extend(env_vars)

        env_content_str = "\n".join(full_env_content) + "\n"

        env_file_path = os.path.join(compose_dir, ".env")
        with open(env_file_path, "w") as env_file:
            env_file.write(env_content_str)
        print(f"Wrote .env file to {os.path.relpath(env_file_path, project_root)}")


if __name__ == "__main__":
    main()

#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#   "colorlog",
#   "pyyaml",
# ]
# ///
import os
import yaml
import configparser
import re
import sys
import logging
import colorlog


def setup_logger():
    """Set up a colored logger."""
    handler = colorlog.StreamHandler()
    handler.setFormatter(
        colorlog.ColoredFormatter("%(log_color)s%(levelname)s: %(message)s")
    )

    logger = colorlog.getLogger("write_dotenvs")
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger


def main():
    """
    Generates .env files for docker-compose files.
    It gets port variables from data/services.yml.
    It auto-detects other required environment variables from the docker-compose files.
    """
    logger = setup_logger()

    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)

    vars_ini_path = os.path.join(project_root, "vars.ini")
    services_yml_path = os.path.join(project_root, "services.yml")
    docker_dir = os.path.join(project_root, "docker")

    # Read domain_name from vars.ini
    config = configparser.ConfigParser()
    config.read(vars_ini_path)
    domain_name = config.get("DEFAULT", "domain_name")

    # Find all docker-compose.yml files
    all_compose_files = set()
    for root, _, files in os.walk(docker_dir):
        for file in files:
            if file == "docker-compose.yml":
                all_compose_files.add(os.path.join(root, file))

    # Get port variables from services.yml
    port_vars_map = {}  # Maps compose_path to a list of port variable strings
    port_var_names = set()
    if os.path.exists(services_yml_path):
        with open(services_yml_path, "r") as f:
            services_data = yaml.safe_load(f)
            for service_name, service_details in services_data.items():
                docker_dir_name = service_details.get("docker")
                if not docker_dir_name:
                    continue

                compose_path = os.path.join(
                    docker_dir, docker_dir_name, "docker-compose.yml"
                )
                if compose_path not in port_vars_map:
                    port_vars_map[compose_path] = []

                port_var_name = f"{service_name.upper().replace('-', '_')}_PORT"
                port_var_names.add(port_var_name)
                port = service_details.get("port")
                if port:
                    port_vars_map[compose_path].append(f"{port_var_name}={port}")

    # Process each compose file
    for compose_path in all_compose_files:
        env_vars = []

        # Add port variables if any are defined for this file
        if compose_path in port_vars_map:
            env_vars.extend(port_vars_map[compose_path])

        # Read compose file and find other required env vars
        with open(compose_path, "r") as f:
            content = f.read()

        regex = re.compile(r"\$\{([A-Z0-9_]+)\}")
        found_vars = set(regex.findall(content))

        for var_name in found_vars:
            # Skip variables that are handled by other means
            if var_name in port_var_names or var_name == "DOMAIN_NAME":
                continue

            # Skip if already added (e.g. from port_vars_map)
            if any(v.startswith(f"{var_name}=") for v in env_vars):
                continue

            value = os.environ.get(var_name)
            if value is None:
                if var_name.endswith("_PORT"):
                    logger.warning(
                        f"Port variable '{var_name}' is used in "
                        f"{os.path.relpath(compose_path, project_root)} but is not defined in "
                        f"services.yml or the environment."
                    )
                    continue
                else:
                    logger.error(
                        f"Environment variable '{var_name}' is used in "
                        f"{os.path.relpath(compose_path, project_root)} but is not set."
                    )
                    sys.exit(1)

            env_vars.append(f"{var_name}={value}")

        # Separate into port and secret variables for ordering
        port_vars_for_file = [v for v in env_vars if v.split("=")[0] in port_var_names]
        secret_vars_for_file = [
            v for v in env_vars if v.split("=")[0] not in port_var_names
        ]

        # Write the .env file for this compose file, only if there are vars other than DOMAIN_NAME
        if not port_vars_for_file and not secret_vars_for_file:
            # If a .env file exists, remove it
            env_file_path = os.path.join(os.path.dirname(compose_path), ".env")
            if os.path.exists(env_file_path):
                os.remove(env_file_path)
                print(
                    f"Removed empty .env file from {os.path.relpath(env_file_path, project_root)}"
                )
            continue

        compose_dir = os.path.dirname(compose_path)
        full_env_content = [
            "# This file is auto-generated",
            f"DOMAIN_NAME={domain_name}",
        ]
        full_env_content.extend(sorted(port_vars_for_file))

        if secret_vars_for_file:
            full_env_content.append("")  # Add a blank line for separation
            full_env_content.extend(sorted(secret_vars_for_file))

        env_content_str = "\n".join(full_env_content) + "\n"

        env_file_path = os.path.join(compose_dir, ".env")
        with open(env_file_path, "w") as env_file:
            env_file.write(env_content_str)
        print(f"Wrote .env file to {os.path.relpath(env_file_path, project_root)}")


if __name__ == "__main__":
    main()

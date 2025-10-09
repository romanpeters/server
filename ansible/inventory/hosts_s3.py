#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#   "boto3",
#   "pyyaml"
# ]
# ///
import os
import sys
import boto3
import yaml
import json
import getpass
import configparser
from botocore.exceptions import NoCredentialsError, ClientError


def get_endpoint_url():
    config = configparser.ConfigParser()
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, "..", ".."))
    vars_ini_path = os.path.join(project_root, "vars.ini")
    config.read(vars_ini_path)
    if "DEFAULT" in config and "aws_endpoint" in config["DEFAULT"]:
        return config["DEFAULT"]["aws_endpoint"]
    return None


def load_hosts_from_s3(bucket_name, object_name):
    endpoint_url = get_endpoint_url()
    if not endpoint_url:
        print(
            "Warning: aws_endpoint not found in vars.ini. Could not load hosts from S3.",
            file=sys.stderr,
        )
        sys.exit(1)

    try:
        s3 = boto3.client(
            "s3",
            endpoint_url=endpoint_url,
            aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY"),
        )
        response = s3.get_object(Bucket=bucket_name, Key=object_name)
        data = yaml.safe_load(response["Body"])
    except NoCredentialsError:
        print("Error: AWS credentials not found.", file=sys.stderr)
        sys.exit(1)
    except ClientError as e:
        if e.response["Error"]["Code"] == "404":
            print(
                f"Error: {object_name} not found in S3 bucket {bucket_name}.",
                file=sys.stderr,
            )
        else:
            print(
                f"Error: An S3 error occurred for {object_name}: {e}.", file=sys.stderr
            )
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred for {object_name}: {e}.", file=sys.stderr)
        sys.exit(1)
    return data


def main():
    hosts_data = load_hosts_from_s3("server", "hosts.yml")

    # Build inventory: ubuntu, rhel, and nixos groups
    inventory = {
        "ubuntu": {"hosts": []},
        "rhel": {"hosts": []},
        "nixos": {"hosts": []},
        "_meta": {"hostvars": {}},
    }
    for name, details in hosts_data.items():
        ip = details.get("ip")
        os_val = details.get("os", "").strip().lower()
        # Only include known Linux OS families
        if os_val not in ("ubuntu", "rhel", "nixos"):
            continue
        # Connect as the current user (root login is disabled)
        user = getpass.getuser()

        inventory[os_val]["hosts"].append(name)
        inventory["_meta"]["hostvars"][name] = {
            "ansible_host": ip,
            "ansible_user": user,
        }

    # Handle --list and --host flags
    if "--list" in sys.argv:
        print(json.dumps(inventory, indent=2))
        return
    if "--host" in sys.argv:
        host = sys.argv[sys.argv.index("--host") + 1]
        print(json.dumps(inventory["_meta"]["hostvars"].get(host, {}), indent=2))
        return

    # Default to list all
    print(json.dumps(inventory, indent=2))


if __name__ == "__main__":
    main()

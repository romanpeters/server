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
import configparser
from botocore.exceptions import NoCredentialsError, ClientError


def get_endpoint_url():
    config = configparser.ConfigParser()
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, ".."))
    vars_ini_path = os.path.join(project_root, "vars.ini")
    config.read(vars_ini_path)
    if "DEFAULT" in config and "aws_endpoint" in config["DEFAULT"]:
        return config["DEFAULT"]["aws_endpoint"]
    return None


def download_from_s3(bucket_name, object_name, dest_path):
    endpoint_url = get_endpoint_url()
    if not endpoint_url:
        print(
            "Warning: aws_endpoint not found in vars.ini. Could not download from S3.",
            file=sys.stderr,
        )
        return

    try:
        s3 = boto3.client(
            "s3",
            endpoint_url=endpoint_url,
            aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY"),
        )
        s3.download_file(bucket_name, object_name, dest_path)
        print(f"Successfully downloaded {object_name} from S3 bucket {bucket_name}.")
    except NoCredentialsError:
        print(
            f"Warning: AWS credentials not found. Could not download {object_name} from S3.",
            file=sys.stderr,
        )
    except ClientError as e:
        if e.response["Error"]["Code"] == "404":
            print(
                f"Warning: {object_name} not found in S3 bucket {bucket_name}. Using local file.",
                file=sys.stderr,
            )
        else:
            print(
                f"Warning: An S3 error occurred for {object_name}: {e}. Using local file.",
                file=sys.stderr,
            )
    except Exception as e:
        print(
            f"An unexpected error occurred for {object_name}: {e}. Using local file.",
            file=sys.stderr,
        )


if __name__ == "__main__":
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    files_to_download = ["hosts.yml", "services.yml"]
    for file_name in files_to_download:
        dest_file = os.path.join(project_root, file_name)
        download_from_s3("server", file_name, dest_file)

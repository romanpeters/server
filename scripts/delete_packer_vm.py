#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#   "proxmoxer",
#   "python-dotenv",
#   "requests"
# ]
# ///

import os
import configparser
from proxmoxer import ProxmoxAPI
from dotenv import load_dotenv
from urllib.parse import urlparse

load_dotenv()


def main():
    """
    Deletes the Packer VM from Proxmox.
    """
    config = configparser.ConfigParser()
    config.read("vars.ini")

    proxmox_api_url = config.get("PACKER", "proxmox_api_url")
    proxmox_node = config.get("PACKER", "proxmox_node")

    user_full = os.getenv("PROXMOX_USERNAME")
    user, realm_token = user_full.split("@")
    realm, token_name = realm_token.split("!")

    parsed_url = urlparse(proxmox_api_url)

    try:
        proxmox = ProxmoxAPI(
            parsed_url.hostname,
            user=f"{user}@{realm}",
            token_name=token_name,
            token_value=os.getenv("PROXMOX_TOKEN"),
            verify_ssl=False,
            port=parsed_url.port,
        )
    except Exception as e:
        print(f"Error connecting to Proxmox: {e}")
        return

    vm_id = 500

    try:
        # Check if the VM exists
        proxmox.nodes(proxmox_node).qemu(vm_id).status.get()
        print(f"VM {vm_id} exists. Deleting...")
        proxmox.nodes(proxmox_node).qemu(vm_id).delete()
        print(f"VM {vm_id} deleted.")
    except Exception as e:
        if "does not exist" in str(e) or "not found" in str(e):
            print(f"VM {vm_id} does not exist. No action needed.")
        else:
            print(f"An error occurred: {e}")


if __name__ == "__main__":
    main()

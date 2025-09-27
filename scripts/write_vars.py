#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
# ]
# ///
import argparse
from configparser import ConfigParser
from pathlib import Path
from typing import Dict
import sys
import subprocess


import json


def get_terraform_output(variable: str) -> str:
    try:
        result = subprocess.run(
            ["terraform", "output", "-json"],
            capture_output=True,
            text=True,
            check=True,
            cwd="terraform",
        )
        outputs = json.loads(result.stdout)
        return outputs.get(variable, {}).get("value", "")
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""


def merge_sections(
    default_section: Dict[str, str], specific_section: Dict[str, str]
) -> Dict[str, str]:
    merged = default_section.copy()
    merged.update(specific_section)
    return merged


def read_ini(filepath: str) -> Dict[str, Dict[str, str]]:
    config = ConfigParser()
    config.optionxform = str
    config.read(filepath)
    default_section = dict(config["DEFAULT"]) if "DEFAULT" in config else {}

    sections = {}
    for section in config.sections():
        sections[section.lower()] = dict(config[section])

    return default_section, sections


def format_variable(key: str, value: str, format_type: str) -> str:
    if value.lower() in {"true", "false"} or value.replace(".", "", 1).isdigit():
        val = value.lower() if value.lower() in {"true", "false"} else value
    else:
        val = f'"{value}"'

    if format_type == "tfvars":
        return f"{key} = {val}"
    elif format_type == "ansible":
        return f"{key}: {val}"
    elif format_type == "nixos":
        return f"  {key} = {val};"
    elif format_type == "pkrvars":
        return f"{key} = {val}"
    else:
        raise ValueError(f"Unknown format type: {format_type}")


def write_vars(vars_dict: Dict[str, str], filepath: str, format_type: str) -> None:
    if not vars_dict:
        print(
            f"Error: No variables to write for {format_type} format. Aborting.",
            file=sys.stderr,
        )
        sys.exit(1)

    lines = []
    lines.append("### This file is generated from vars.ini")
    if format_type == "nixos":
        lines.append("{ ")
    for k, v in vars_dict.items():
        lines.append(format_variable(k, v, format_type))
    if format_type == "nixos":
        lines.append("}")
    Path(filepath).write_text("\n".join(lines) + "\n")
    print(f"Wrote {format_type.capitalize()} variables to {filepath}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate variable files.")
    parser.add_argument(
        "--format",
        choices=["terraform", "ansible", "nixos", "packer"],
        help="Specify the format to generate variables for.",
    )
    args = parser.parse_args()

    vars_ini_path = Path(__file__).parent.parent / "vars.ini"
    if not vars_ini_path.exists():
        print(f"Error: vars.ini not found at {vars_ini_path}", file=sys.stderr)
        sys.exit(1)

    default_section, sections = read_ini(vars_ini_path)

    if not args.format or args.format == "terraform":
        terraform_vars = merge_sections(default_section, sections.get("terraform", {}))
        write_vars(terraform_vars, "terraform/vars.tfvars", "tfvars")
        subprocess.run(["terraform", "fmt", Path("terraform/vars.tfvars")], check=True)

    if not args.format or args.format == "ansible":
        ansible_vars = merge_sections(default_section, sections.get("ansible", {}))

        write_vars(ansible_vars, "ansible/vars/main.yml", "ansible")

    if not args.format or args.format == "nixos":
        nix_vars = merge_sections(default_section, sections.get("nixos", {}))
        write_vars(nix_vars, "nixos/vars.nix", "nixos")

    if not args.format or args.format == "packer":
        packer_vars = merge_sections(default_section, sections.get("packer", {}))
        write_vars(packer_vars, "packer/vars.pkrvars.hcl", "pkrvars")


if __name__ == "__main__":
    main()

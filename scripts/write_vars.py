#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
# ]
# ///
from configparser import ConfigParser
from pathlib import Path
from typing import Dict
import sys
import subprocess


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
    lines.append("### This file is generated from data/vars.ini")
    if format_type == "nixos":
        lines.append("{")
    for k, v in vars_dict.items():
        lines.append(format_variable(k, v, format_type))
    if format_type == "nixos":
        lines.append("}")
    Path(filepath).write_text("\n".join(lines) + "\n")
    print(f"Wrote {format_type.capitalize()} variables to {filepath}")


def main() -> None:
    vars_ini_path = Path(__file__).parent.parent / "data/vars.ini"
    if not vars_ini_path.exists():
        print(f"Error: vars.ini not found at {vars_ini_path}", file=sys.stderr)
        sys.exit(1)

    default_section, sections = read_ini(vars_ini_path)

    terraform_vars = merge_sections(default_section, sections.get("terraform", {}))
    ansible_vars = merge_sections(default_section, sections.get("ansible", {}))
    nix_vars = merge_sections(default_section, sections.get("nixos", {}))

    write_vars(terraform_vars, "terraform/vars.tfvars", "tfvars")
    subprocess.run(["terraform", "fmt", Path("terraform/vars.tfvars")], check=True)
    write_vars(ansible_vars, "ansible/vars/main.yml", "ansible")
    write_vars(nix_vars, "nixos/vars.nix", "nixos")


if __name__ == "__main__":
    main()

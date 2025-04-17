#!/usr/bin/env nix-shell
#! nix-shell -i bash -p python3 python3Packages.molecule python3Packages.ansible docker
set -euo pipefail

# Run Molecule scenario for the webserver role
molecule test -s webserver
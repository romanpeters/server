#!/usr/bin/bash

# change the current working directory to the script's directory if needed
cd "$(dirname "$0")";

source ../data/.envrc;

terraform apply -var-file=vars.tfvars;

echo "\nRunning host status check...\n";
../tests/host_status.py;

echo "\nRunning DNS status check...\n";
../tests/dns_resolution.py;

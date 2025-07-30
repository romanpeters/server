# change the current working directory to the script's directory if needed
cd "$(dirname "$0")";

# if arg is provided, use it as the playbook file
if [ -n "$1" ]; then
    playbook_file="$1"
else
    playbook_file="configure_hosts.yml"
fi

ansible-playbook -i inventory/hosts_csv.py playbooks/"$playbook_file"

echo "\nRunning HTTP status check...\n";
../tests/http_status.py;

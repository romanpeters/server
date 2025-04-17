pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

    stages {

        stage('Terraform Apply') {
            steps {
                script {
                    sh 'cd terraform'
                    sh 'terraform init -upgrade'
                    sh 'terraform apply -auto-approve -var-file=vars.tfvars'
                }
            }
        }

        stage('Configure NixOS Hosts') {
            steps {
                script {
                    // Deploy NixOS configurations to all hosts marked as nixos
                    sh 'ansible-playbook -i ansible/inventory/hosts_csv.py ansible/playbooks/nixos_deploy.yml'
                }
            }
        }

        stage('Configure Webserver') {
            steps {
                script {
                    // Configure Nginx reverse proxy on the webserver host
                    sh 'ansible-playbook -i ansible/inventory/hosts_csv.py ansible/playbooks/webserver.yml'
                }
            }
        }
    }

}
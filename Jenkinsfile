pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

    stages {

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init -upgrade'
                    sh 'terraform apply -auto-approve -var-file=vars.tfvars'
                script {
                    sh 'cd terraform'
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Configure NixOS Hosts') {
            steps {
                dir('ansible') {
                    // Deploy NixOS configurations to all hosts marked as nixos
                    sh 'ansible-playbook -i inventory/hosts_csv.py playbooks/nixos_deploy.yml'
                }
            }
        }

        stage('Configure Webserver') {
            steps {
                dir('ansible') {
                    // Configure Nginx reverse proxy on the webserver host
                    sh 'ansible-playbook -i inventory/hosts_csv.py playbooks/webserver.yml'
                }
            }
        }
    }

}

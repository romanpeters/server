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
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        // stage('NixOS Build') {
        //     steps {
        //         script {
        //             sh 'nix-build'
        //         }
        //     }
        // }   

        // stage('Ansible Configure') {
        //     steps {
        //         script {
        //             sh 'ansible-playbook -i inventory.ini configure_infrastructure.yml'
        //         }
        //     }
        // }
    }

}
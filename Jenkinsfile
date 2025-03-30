pipeline {
    agent any

    stages {
        stage('Static analysis') {
            steps {
                script {
                    try {
                        sh 'pylint --fail-under=5 --disable=E0401 web_app_project/weather.py'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Static analysis'
                        error('Static analysis failed')
                    }
                }
            }
        }

        stage('Dependency Scanning') {
            steps {
                script {
                    try {
                        env.LAST_FAILED_STAGE = 'Dependency Scanning'
                        sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin'
                        sh 'trivy --version'
                        // Run Trivy scan for dependencies
                        sh 'trivy fs . --severity HIGH,CRITICAL --format json > trivy-report.json'

                        // Check for critical vulnerabilities
                        def criticalVulns = sh(
                            script: "cat trivy-report.json | jq '.Results[].Vulnerabilities[] | select(.Severity == \"CRITICAL\")' | wc -l",
                            returnStdout: true
                        ).trim()
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Dependency Scanning'
                        error('Dependency scanning failed')
                    }
                }
            }
        }

        stage('Docker File Scan') {
            steps {
                script {
                    try {
                        sh '''
                        if ! command -v hadolint &> /dev/null
                        then
                            curl -sL https://github.com/hadolint/hadolint/releases/download/v2.10.0/hadolint-Linux-x86_64 -o hadolint
                            chmod +x hadolint
                            sudo mv hadolint /usr/local/bin
                        fi
                        hadolint Dockerfile
                        '''
                        sh 'hadolint Dockerfile'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Docker File Scan'
                        error('Docker file scan failed')
                    }
                }
            }
        }

        stage('Build image') {
            steps {
                script {
                    try {
                        def commitHash = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
                        // Login to Docker Hub
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
                            sh "docker login -u ${dockerHubUser} -p ${dockerHubPassword}"
                        }
                        sh 'docker compose build'
                        sh 'docker images'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Build image'
                        error('Build image failed')
                    }
                }
            }
        }

        stage('Tests') {
            steps {
                script {
                    try {
                        // Update package lists and install necessary tools
                        sh 'sudo apt-get update -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true || true'
                        sh 'sudo apt-get install -y --allow-unauthenticated python3-pip'
                        sh 'docker compose up -d'
                        sh 'pip install -r ./requirements.txt --break-system-packages'
                        sh 'pytest test_weather.py'
                        sh 'docker compose down'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Tests'
                        error('Tests failed')
                    }
                }
            }
        }

        stage('Publish') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
                            sh "docker login -u ${dockerHubUser} -p ${dockerHubPassword}"
                            def commitHash = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
                            sh "docker tag flask_app orielzigdon/flask_app:${commitHash}"
                            sh "docker push orielzigdon/flask_app:${commitHash}"
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Publish'
                        error('Publish failed')
                    }
                }
            }
        }
/*
        stage('Sign Artifacts') {
            steps {
                script {
                    try {
                        def commitHash = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()

                        withCredentials([
                        file(credentialsId: 'COSIGN_KEY', variable: 'COSIGN_KEY_FILE'),
                        string(credentialsId: 'cosign-password', variable: 'COSIGN_PASSWORD')
                    ]) {
                        sh '''
                            echo "Downloading cosign..."
                            curl -sSL -o ~/cosign https://github.com/sigstore/cosign/releases/download/v2.4.1/cosign-linux-amd64
                            echo "Setting up cosign..."
                            chmod +x ~/cosign
                            sudo mv ~/cosign /usr/local/bin/cosign
                            cosign version
                        '''
                        // Sign the Docker image
                        sh """
                            echo "Signing Docker image..."
                            COSIGN_PASSWORD=\$COSIGN_PASSWORD cosign sign -y --key \$COSIGN_KEY_FILE orielzigdon/flask_app:${commitHash}
                        """
                    }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Sign Artifacts'
                        error('Signing artifacts failed')
                    }
                }
            }
        }

        stage('Verify Docker Image') {
            steps {
                script {
                    try {
                        def commitHash = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
                        withCredentials([file(credentialsId: 'cosing-pub-key', variable: 'COSIGN_PUB_FILE')]) {
                            sh """
                                cosign verify --key \$COSIGN_PUB_FILE orielzigdon/flask_app:${commitHash}
                            """
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Verify Docker Image'
                        error('Verification of Docker image failed')
                    }
                }
            }
        }*/


        stage('Deploy to EKS') {
            when {
                branch 'master'
            }
            steps {
                script {
                    try {
                        withCredentials([aws(credentialsId: 'jenkins-aws-access')]) {
                            sh 'sudo apt-get update'
                            sh 'sudo apt-get install -y unzip curl'

                            // Install kubectl
                            sh '''
                            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                            kubectl version --client
                            '''

                            // Install AWS CLI
                            sh '''
                            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                            unzip -q awscliv2.zip
                            sudo ./aws/install --update >/dev/null 2>&1
                            aws --version
                            '''

                            // Configure AWS CLI with the provided credentials
                            sh 'aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}'
                            sh 'aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}'
                            sh 'aws configure set default.region eu-north-1'

                            // Update kubeconfig and deploy to EKS
                            sh 'aws eks --region eu-north-1 update-kubeconfig --name weather_app_eks'
                            sh 'kubectl apply -f flask-deployment.yaml'
                            sh 'kubectl apply -f flask-service.yaml'

                            // Get the EXTERNAL-IP of the service
                            def externalIP = sh(script: 'kubectl get svc flask-service -o=jsonpath="{.status.loadBalancer.ingress[0].hostname}"', returnStdout: true).trim()

                            // Print the EXTERNAL-IP in logs
                            echo "Application is accessible at: http://${externalIP}"

                            // Send the EXTERNAL-IP to Slack
                            slackSend(channel: '#succeeded-build', message: "The application is deployed and accessible at: http://${externalIP}", color: 'good')

                            // Check Pods Status
                            echo "Checking Pods status..."
                            sh 'kubectl get pods --namespace=default'
                            sh 'kubectl describe pods --namespace=default'
                            sh 'kubectl get pods --namespace=default | grep Running'
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Deploy'
                        error('Deploy failed')
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'docker system prune -af --volumes || true'
                cleanWs()
            }
        }
        success {
            script {
                slackSend(channel: '#succeeded-build', message: "Build succeeded! Build number: ${env.BUILD_NUMBER}", color: 'good')
            }
        }
        failure {
            script {
                def failedStage = env.FAILED_STAGE ?: 'Unknown stage'
                def slackMessage = "Build failed at stage '${failedStage}'! Build number: ${env.BUILD_NUMBER}."

                try {
                    slackSend(channel: '#DevOps-alerts', message: slackMessage, color: 'danger')
                } catch (Exception e) {
                    echo "Failed to send message to Slack: ${e.message}"
                }
            }
        }
    }
}
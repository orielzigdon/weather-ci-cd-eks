pipeline {
    agent any

    environment {
        ARGOCD_REPO_URL = 'https://github.com/orielzigdon/weather-ci-cd-eks-iac.git'
        DOCKER_IMAGE = 'orielzigdon/flask_app'
        HELM_CHART_PATH = './helm'
    }

    stages {
        stage('Static analysis') {
            steps {
                script {
                    try {
                        sh 'pylint --fail-under=5 --disable=E0401 web_app_project/weather.py'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Static analysis'
                        slackSend(channel: '#DevOps-alerts', message: "Static analysis failed: ${e.message}", color: 'danger')
                        error('Static analysis failed')
                    }
                }
            }
        }

        stage('Dependency Scanning') {
            steps {
                script {
                    try {
                        sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin'
                        sh 'trivy fs . --severity HIGH,CRITICAL --format json > trivy-report.json'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Dependency Scanning'
                        slackSend(channel: '#DevOps-alerts', message: "Dependency scanning failed: ${e.message}", color: 'danger')
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
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Docker File Scan'
                        slackSend(channel: '#DevOps-alerts', message: "Docker file scan failed: ${e.message}", color: 'danger')
                        error('Docker file scan failed')
                    }
                }
            }
        }

        stage('Build image') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
                            sh "docker login -u ${dockerHubUser} -p ${dockerHubPassword}"
                        }
                        sh 'docker compose build'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Build image'
                        slackSend(channel: '#DevOps-alerts', message: "Build image failed: ${e.message}", color: 'danger')
                        error('Build image failed')
                    }
                }
            }
        }

        stage('Tests') {
            steps {
                script {
                    try {
                        sh 'docker compose up -d'
                        sh 'pip install -r ./requirements.txt --break-system-packages'
                        sh 'pytest test_weather.py'
                        sh 'docker compose down'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Tests'
                        slackSend(channel: '#DevOps-alerts', message: "Tests failed: ${e.message}", color: 'danger')
                        error('Tests failed')
                    }
                }
            }
        }

        stage('Publish') {
            steps {
                script {
                    try {
                        def commitHash = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
                            sh "docker login -u ${dockerHubUser} -p ${dockerHubPassword}"
                            sh "docker tag flask_app ${DOCKER_IMAGE}:${commitHash}"
                            sh "docker push ${DOCKER_IMAGE}:${commitHash}"
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Publish'
                        slackSend(channel: '#DevOps-alerts', message: "Publish failed: ${e.message}", color: 'danger')
                        error('Publish failed')
                    }
                }
            }
        }

        stage('Deploy to EKS with Helm and Update ArgoCD') {
            when {
                branch 'master'
            }
            steps {
                script {
                    try {
                        withCredentials([aws(credentialsId: 'jenkins-aws-access')]) {
                            sh 'aws eks --region eu-north-1 update-kubeconfig --name weather_app_eks'
                            sh "helm upgrade --install weather-app ${HELM_CHART_PATH} --set image.repository=${DOCKER_IMAGE},image.tag=${commitHash}"
                            dir('argocd-configs') {
                                git url: ARGOCD_REPO_URL
                                sh "sed -i 's|image.tag:.*|image.tag: ${commitHash}|g' values.yaml"
                                sh 'git config user.email "jenkins@example.com"'
                                sh 'git config user.name "Jenkins CI"'
                                sh "git commit -am 'Update app to ${commitHash}' || echo 'No changes to commit'"
                                sh 'git push origin main'
                            }
                            slackSend(channel: '#succeeded-build', message: "Deployed and updated ArgoCD", color: 'good')
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.FAILED_STAGE = 'Deploy and Update ArgoCD'
                        slackSend(channel: '#DevOps-alerts', message: "Deploy and ArgoCD update failed: ${e.message}", color: 'danger')
                        error('Deploy and ArgoCD update failed')
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker system prune -af --volumes || true'
            cleanWs()
        }
        success {
            slackSend(channel: '#succeeded-build', message: "Build succeeded: ${env.BUILD_NUMBER}", color: 'good')
        }
    }
}

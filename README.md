# Weather CI/CD with EKS

## Project Overview

This project provides a CI/CD pipeline for a Flask-based weather application deployed on Amazon EKS. The pipeline automates building, testing, containerizing, deploying, and includes notifications via Slack.

## Project Structure

- **infra/**: Terraform infrastructure configuration
- **web_app_project/**: Flask application source code
- **Dockerfile**: Docker image build instructions
- **Jenkinsfile**: CI/CD pipeline definition for Jenkins
- **docker-compose.yml**: Local development configuration
- **k8s/**:
  - **flask-deployment.yaml**: Kubernetes Deployment manifest
  - **flask-service.yaml**: Kubernetes Service manifest
- **requirements.txt**: Python dependencies
- **test_weather.py**: Unit tests for the application

## Prerequisites

- **AWS Account** with EKS access
- **Docker** installed locally
- **Jenkins** with access to Docker and Kubernetes
- **Terraform** installed (for infrastructure setup)
- **Slack webhook URL** for notifications

## Installation & Setup

### Clone the Repository

```bash
git clone https://github.com/orielzigdon/weather-ci-cd-eks.git
cd weather-ci-cd-eks
```

### Build and Run Locally

```bash
docker build -t weather-app:latest .
docker-compose up
```

The application will be available at `http://localhost:5000`.

## Deploying to EKS

### Infrastructure Setup with Terraform

```bash
cd infra/
terraform init
terraform apply
```

### Deploy Application to Kubernetes

```bash
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/flask-service.yaml
```

Check deployment:

```bash
kubectl get pods
kubectl get services
```

## Jenkins CI/CD Pipeline

The **Jenkinsfile** defines the pipeline with the following stages:

The **Jenkinsfile** defines the pipeline with the following stages:

1. **Checkout**: Retrieves the latest code from the repository.
2. **Build**: Builds the Docker image for the Flask application.
3. **Test**: Runs unit tests.
4. **Linting**: Runs `flake8` to check for code quality issues.
5. **Secret Scanning**: Scans the repository for exposed secrets using tools like `trufflehog` or `gitleaks`.
6. **Dependency Scanning**: Checks dependencies for known vulnerabilities using `safety` or `OWASP Dependency-Check`.
7. **Docker Image Security Scan**: Runs a security scan on the built Docker image using `Trivy` or `Anchore`.
8. **Static Code Analysis**: Performs static code analysis to detect security issues in the code.
9. **Push**: Pushes the Docker image to the container registry.
10. **Deploy**: Deploys the application to the EKS cluster using Kubernetes manifests.
11. **Container Signing & Verification**: Signs and verifies container images to ensure integrity before deployment.
12. **Notify**: Sends a Slack notification with the build and deployment status.

## Monitoring & Logging

- **Application Logs**:

  ```bash
  kubectl logs -l app=weather-app
  ```

- **Check Running Services**:

  ```bash
  kubectl get pods
  kubectl get services
  ```

## License

This project is licensed under the MIT License.

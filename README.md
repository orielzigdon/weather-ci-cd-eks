# Weather App - DevOps Overview

## Overview
This Weather App is a Flask-based web application that retrieves weather data using external APIs and serves dynamic web pages based on user inputs.

## Application Components
- **Flask Web Application** (`weather.py`)
- **API Integration** (`get_info.py`)
- **Docker Containerization**
- **CI/CD Pipeline with Jenkins**
- **Kubernetes Deployment (EKS)**
- **Helm Charts for Kubernetes Management**
- **GitOps via ArgoCD**

## DevOps Process

### 1. Continuous Integration (CI)
Managed via Jenkins Pipeline:

- **Static Code Analysis** using `pylint`.
- **Dependency Scanning** with `Trivy` to identify vulnerabilities.
- **Dockerfile Security Scanning** using `Hadolint`.
- **Automated Testing** via `pytest`.
- **Docker Image Building and Tagging**.

### 2. Container Management
- **Docker Compose** used locally for testing and development.
- Docker images published automatically to **Docker Hub** upon successful CI stages.

### 3. Continuous Deployment (CD)
Automated deployment pipeline:

- **Kubernetes (EKS)** deployment managed with **Helm Charts** for infrastructure as code (IaC).
- Helm facilitates seamless updates and rollbacks.
- Kubernetes resources such as Deployments, Services (LoadBalancer), and ConfigMaps are managed systematically.

### 4. GitOps with ArgoCD
- **ArgoCD** automatically synchronizes Kubernetes clusters to match the state defined in Git repositories.
- After every successful deployment, Jenkins automatically updates the `values.yaml` file in the ArgoCD Git repository to trigger synchronization.

## Deployment Steps in CI/CD
1. **Static Analysis** – Validate code quality.
2. **Dependency & Security Scanning** – Ensure dependencies and Dockerfiles are secure.
3. **Docker Build & Publish** – Create and upload Docker images to Docker Hub.
4. **Deploy to Kubernetes (EKS)** – Use Helm to deploy the application to Amazon EKS.
5. **GitOps (ArgoCD)** – Automatically update GitOps configuration in Git repository, initiating ArgoCD synchronization.

## Monitoring and Alerts
- Pipeline events (success/failure) reported via **Slack integration**.
- Detailed logs and status updates provided for each pipeline stage.

## Technologies Used
- **Flask** for the backend web service.
- **Docker** & **Docker Compose** for containerization.
- **Jenkins** for CI/CD automation.
- **Amazon EKS (Kubernetes)** for production orchestration.
- **Helm** for Kubernetes package management.
- **ArgoCD** for continuous delivery and GitOps.
- **AWS CLI & kubectl** for Kubernetes cluster management.

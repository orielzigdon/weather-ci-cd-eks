# 🌦️ Weather CI/CD with EKS 🚀

## 📌 Project Overview

This project provides a **CI/CD pipeline** for a **Flask-based weather application** deployed on **Amazon EKS**.  
The pipeline automates **building, testing, containerizing, deploying**, and includes **Slack notifications**.  

---

## 📂 Project Structure

📁 **infra/** - Terraform infrastructure configuration  
📁 **web_app_project/** - Flask application source code  
📄 **Dockerfile** - Docker image build instructions  
📄 **Jenkinsfile** - CI/CD pipeline definition for Jenkins  
📄 **docker-compose.yml** - Local development configuration  
📁 **k8s/** - Kubernetes deployment and service manifests  
📄 **requirements.txt** - Python dependencies  
🧪 **test_weather.py** - Unit tests for the application  

---

## ⚡ Prerequisites

✔ **AWS Account** with EKS access  
✔ **Docker** installed locally  
✔ **Jenkins** with access to Docker and Kubernetes  
✔ **Terraform** installed (for infrastructure setup)  
✔ **Slack webhook URL** for notifications  

---

## 🛠️ Installation & Setup

### 📥 Clone the Repository

```bash
git clone https://github.com/orielzigdon/weather-ci-cd-eks.git
cd weather-ci-cd-eks
```

### 🏗️ Build and Run Locally

```bash
docker build -t weather-app:latest .
docker-compose up
```

📌 The application will be available at **`http://localhost:5000`**.

---

## ☁️ Deploying to EKS

### 🏗️ Infrastructure Setup with Terraform

```bash
cd infra/
terraform init
terraform apply
```

### 🚀 Deploy Application to Kubernetes

```bash
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/flask-service.yaml
```

✔ **Check deployment status:**

```bash
kubectl get pods
kubectl get services
```

---

## 🔄 Jenkins CI/CD Pipeline

The **Jenkinsfile** defines the pipeline with the following stages:

1️⃣ **Checkout** - Retrieves the latest code from the repository  
2️⃣ **Build** - Builds the Docker image for the Flask application  
3️⃣ **Test** - Runs unit tests 🧪  
4️⃣ **Linting** - Runs `flake8` to check for code quality issues  
5️⃣ **Secret Scanning** - Scans for exposed secrets 🔍  
6️⃣ **Dependency Scanning** - Checks for known vulnerabilities 🔒  
7️⃣ **Docker Image Security Scan** - Scans the image for security issues 🚨  
8️⃣ **Static Code Analysis** - Detects security issues in the code 🔍  
9️⃣ **Push** - Pushes the Docker image to the registry 📦  
🔟 **Deploy** - Deploys the application to the EKS cluster ☁️  
1️⃣1️⃣ **Container Signing & Verification** - Ensures image integrity ✅  
1️⃣2️⃣ **Notify** - Sends a Slack notification with the build and deployment status 📢  

---

## 📊 Monitoring & Logging

🔍 **Application Logs:**

```bash
kubectl logs -l app=weather-app
```

✔ **Check Running Services:**

```bash
kubectl get pods
kubectl get services
```

---

🚀 **Happy Coding!** 😃

#  Project 1
## CI/CD DevOps Pipeline Project: Deployment of Java Application on Kubernetes
---
## Introduction
In the rapidly evolving landscape of software development, adopting DevOps practices has become essential for organizations aiming for agility, efficiency, and quality in their software delivery processes. This project focuses on implementing a robust DevOps Continuous Integration/Continuous Deployment (CI/CD) pipeline, orchestrated by Jenkins, to streamline the development, testing, and deployment phases of a software product.

---
## Architecture
![image](https://github.com/user-attachments/assets/e912b17e-aa63-43e8-ae46-e36a3f6a2e81)

---
## Purpose and Objectives
The primary purpose of this project is to automate the software delivery lifecycle, from code compilation to deployment, thereby accelerating time-to-market, enhancing product quality, and reducing manual errors. The key objectives include:

- Establishing a seamless CI/CD pipeline using Jenkins to automate various stages of the software delivery process.

- Integrating essential DevOps tools such as Maven, SonarQube, Trivy, Nexus Repository, Docker, Kubernetes, Prometheus, and Grafana to ensure comprehensive automation and monitoring.

- Improving code quality through static code analysis and vulnerability scanning.

- Ensuring reliable and consistent deployments on a Kubernetes cluster with proper load balancing.

- Facilitating timely notifications and alerts via email integration for efficient communication and incident management.

- Implementing robust monitoring and alerting mechanisms to track system health and performance.

---
## Tools Used

* Jenkins: Automation orchestration for CI/CD pipeline.

* Maven: Build automation and dependency management.

* SonarQube: Static code analysis for quality assurance.

* Trivy: Vulnerability scanning for Docker images.

* Nexus Repository: Artifact management and version control.

* Docker: Containerization for consistency and portability.

* Kubernetes: Container orchestration for deployment.

* Gmail Integration: Email notifications for pipeline status.

* Prometheus and Grafana: Monitoring and visualization of system metrics.

* AWS: Creating virtual machines.
---
## Segment 1: Setting up Virtual Machines on AWS - IaC using Terraform
To establish the infrastructure required for the DevOps tools setup, virtual machines were provisioned on the Amazon Web Services (AWS) platform. Each virtual machine served a specific purpose in the CI/CD pipeline. Here's an overview of the virtual machines created for different tools:

1- Kubernetes Master Node: This virtual machine served as the master node in the Kubernetes cluster. It was responsible for managing the cluster's state, scheduling applications, and coordinating communication between cluster nodes.

2- Kubernetes Worker Node 1 and Node 2: These virtual machines acted as worker nodes in the Kubernetes cluster, hosting and running containerized applications. They executed tasks assigned by the master node and provided resources for application deployment and scaling.

3- SonarQube Server: A dedicated virtual machine hosted the SonarQube server, which performed static code analysis to ensure code quality and identify potential issues such as bugs, code smells, and security vulnerabilities.

4- Nexus Repository Manager: Another virtual machine hosted the Nexus Repository Manager, serving as a centralized repository for storing and managing build artifacts, Docker images, and other dependencies used in the CI/CD pipeline.

5- Jenkins Server: A virtual machine was allocated for the Jenkins server, which served as the central hub for orchestrating the CI/CD pipeline. Jenkins coordinated the execution of pipeline stages, triggered builds, and integrated with other DevOps tools for seamless automation.

6- Monitoring Server (Prometheus and Grafana): A single virtual machine hosted both Prometheus and Grafana for monitoring and visualization of system metrics. Prometheus collected metrics from various components of the CI/CD pipeline, while Grafana provided interactive dashboards for real-time monitoring and analysis. 4 Each virtual machine was configured with the necessary resources, including CPU, memory, and storage, to support the respective tool's functionalities and accommodate the workload demands of the CI/CD pipeline. Additionally, security measures such as access controls, network configurations, and encryption were implemented to safeguard the virtualized infrastructure and data integrity.



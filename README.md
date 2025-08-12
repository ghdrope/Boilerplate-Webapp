# Boilerplate Webapp

This repository contains a full-stack boilerplate application composed of multiple components designed to work seamlessly together. The project is structured to support modern development workflows, including CI/CD, containerization, GitOps deployment, and comprehensive testing and security scanning.

---

## Quick Access

[![Documentation](https://img.shields.io/badge/Documentation-white?plastic&logo=docusaurus&logoColor=blue&color=yellow&link=https%3A%2F%2Fwww.notion.so%2FSIMUStack-1f471badea8b80719cc8f94476e146a0%3Fpvs%3D4
)](https://www.notion.so/Boilerplate-Webapp-23371badea8b80299ce9e76ef17188ba?pvs=25)

---

## Project Structure

- **`frontend/`**  
  The React-based frontend application built with TypeScript. Responsible for the user interface and client-side logic.

- **`backend/`**  
  Kotlin Spring Boot backend service providing REST APIs for the frontend and other clients.

- **`grpc/`**  
  gRPC service implementation in Go, facilitating high-performance RPC communication.

- **`docker/`**  
  Dockerfiles for building container images of each component, optimized with multi-stage builds.

- **`tests/`**  
  Contains the `system/` and `e2e/` directories where system and end-to-end tests for the application are built and maintained.

- **`.zap/`**  
  Houses the security rules and configurations used by DAST (Dynamic Application Security Testing) workflows.

- **`.github/workflows/`**  
  GitHub Actions workflows covering linting, building, and testing (unit, integration, system, end-to-end), as well as SAST and DAST security scans.

- **`compose/`**  
  Docker Compose configuration for running all services locally in a unified environment.

- **`charts/`**  
  Helm charts for packaging and deploying all services (frontend, backend, gRPC) into Kubernetes clusters.

- **`cd/`**  
  Configuration files for Argo CD to enable GitOps-style continuous delivery of the Helm charts.

---

## Overview

This boilerplate is designed to accelerate development by providing ready-to-use infrastructure for:

- Building and testing services with automated CI.
- Containerizing applications using Docker with optimized Dockerfiles.
- Deploying applications to Kubernetes clusters using Helm and Argo CD.
- Supporting a clear separation of concerns between frontend, backend, and RPC communication layers.
- Implementing comprehensive testing strategies including unit, integration, system, and end-to-end tests.
- Integrating security scanning workflows including SAST (Static Application Security Testing) and DAST (Dynamic Application Security Testing)

Feel free to explore each folder for more details, and contribute or customize according to your needs!

---

## License

This project is licensed under the [MIT License](LICENSE).

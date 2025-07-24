# Boilerplate Webapp

This repository contains a full-stack boilerplate application composed of multiple components designed to work seamlessly together. The project is structured to support modern development workflows, including CI/CD, containerization, and GitOps deployment.

---

## Quick Access

[![Documentation](https://img.shields.io/badge/Documentation-white?plastic&logo=docusaurus&logoColor=blue&color=yellow&link=https%3A%2F%2Fwww.notion.so%2FSIMUStack-1f471badea8b80719cc8f94476e146a0%3Fpvs%3D4
)](https://www.notion.so/Boilerplate-Webapp-23371badea8b80299ce9e76ef17188ba?pvs=25)

---

## Project Structure

- **`frontend/`**  
  The React-based frontend application built with TypeScript. Responsible for the user interface and client-side logic.

- **`backend/`**  
  A Kotlin Spring Boot backend service providing REST APIs for the frontend and other clients.

- **`grpc/`**  
  gRPC service implementation in Go, facilitating high-performance RPC communication.

- **`docker/`**  
  Dockerfiles for building container images of each component, optimized with multi-stage builds.

- **`.github/workflows/`**  
  GitHub Actions workflows for CI/CD pipelines, automating build, test, and deployment processes.

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
- Containerizing applications using Docker.
- Deploying applications to Kubernetes using Helm and Argo CD.
- Maintaining clear separation of concerns between frontend, backend, and service communication.

Feel free to explore each folder for more details, and contribute or customize according to your needs!

---

## License

This project is licensed under the [MIT License](LICENSE).
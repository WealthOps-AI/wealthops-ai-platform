# wealthops-ai-platform

Local Docker Compose topology and production Kubernetes/AWS deployment ownership. Local Compose is the developer runtime; production is AWS EKS. Kubernetes manifests and Terraform infrastructure are intentionally skeleton-only at this stage.

## Local quick start

The [local setup guide](./local/README.md) links to the primary [Linux/macOS instructions](./local/GETTING-STARTED-LINUX-MACOS.md) and the [Windows alternative](./local/GETTING-STARTED-WINDOWS.md). The [specifications repository](https://github.com/WealthOps-AI/wealthops-ai-specifications) documents architecture and repository ownership.

The local `.env` is git-ignored; its development key and PostgreSQL credentials must never be reused in deployed environments.

## Service topology

Compose includes PostgreSQL, a one-shot database migrator/seeder, the .NET API, an Nginx HTTPS edge that serves the web UI and reverse-proxies the API, Kafka, and an optional Airflow standalone container. Kafka and Airflow currently provide infrastructure skeletons; business consumers and DAG logic remain pending. Kong remains part of the planned production gateway architecture, not the local Compose request path.

Production EKS/IAM/MSK/RDS deployment is not implemented. See the [local development guide](https://github.com/WealthOps-AI/wealthops-ai-specifications/blob/master/21-local-development-guide.md) and [repository topology](https://github.com/WealthOps-AI/wealthops-ai-specifications/blob/master/20-repository-topology.md).

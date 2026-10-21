# Production platform skeleton

Production deployment target: AWS EKS with Kubernetes/Helm, RDS PostgreSQL, MSK Kafka, S3, Secrets Manager, and CloudWatch/OpenTelemetry. Terraform modules and release templates are intentionally not implemented in this foundation milestone.

The legacy .NET Framework 4.8.1 adapter requires a separately validated Windows-compatible hosting path and is not assumed to run on Linux EKS nodes.

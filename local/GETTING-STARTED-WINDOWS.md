# Getting Started on Windows

## Prerequisites

- Docker Desktop using Linux containers, or another running Docker Engine with Docker Compose v2.
- PowerShell.
- [mkcert](https://github.com/FiloSottile/mkcert) for a locally trusted TLS certificate.
- No host-installed .NET, Node.js, PostgreSQL, Kafka, or Airflow is needed for the Compose workflow.

The local environment file contains synthetic development values. Keep your `.env` local and never reuse these values in a deployed environment.

## Check out the repositories

The platform Compose file builds the backend and web images and mounts pipeline DAGs from sibling repositories. In a parent workspace directory, clone the four repositories with their expected folder names:

```powershell
git clone https://github.com/WealthOps-AI/wealthops-ai-platform.git
git clone https://github.com/WealthOps-AI/wealthops-ai-be.git
git clone https://github.com/WealthOps-AI/wealthops-ai-web.git
git clone https://github.com/WealthOps-AI/wealthops-ai-pipelines.git
```

Run the commands below from that parent workspace directory.

## Configure local DNS and TLS

Add this entry to `C:\Windows\System32\drivers\etc\hosts` using an editor running as Administrator:

```text
127.0.0.1 wealthops-ai.local
```

Install mkcert using its official instructions, then open PowerShell and create a locally trusted certificate:

```powershell
.\wealthops-ai-platform\local\scripts\windows\generate-local-certificate.ps1
```

The script writes the certificate and private key to the git-ignored `local\config\certs` directory. `mkcert -install` adds its local CA to the current machine's trust store and may require Administrator approval. Do not share or commit the generated private key.

## Start the core application

From the workspace root in PowerShell, create the local environment file:

```powershell
Copy-Item .\wealthops-ai-platform\local\config\.env.example .\wealthops-ai-platform\local\config\.env
```

Start the stack:

```powershell
.\wealthops-ai-platform\local\scripts\windows\start-local.ps1
```

The app applies EF Core migrations and loads deterministic Development seed data on first startup.

To also start the standalone Kafka and Airflow infrastructure containers:

```powershell
.\wealthops-ai-platform\local\scripts\windows\start-local.ps1 -Full
```

These optional containers are not yet connected to application event processing or data pipelines.

## Verify and operate

Check API authentication and service status, then stop the stack while preserving its data volumes:

```powershell
.\wealthops-ai-platform\local\scripts\windows\smoke-test.ps1
docker compose --env-file .\wealthops-ai-platform\local\config\.env -f .\wealthops-ai-platform\local\compose\compose.yml ps
docker compose --env-file .\wealthops-ai-platform\local\config\.env -f .\wealthops-ai-platform\local\compose\compose.yml down
```

Rerun the idempotent sample-data seed when needed:

```powershell
.\wealthops-ai-platform\local\scripts\windows\load-sample-data.ps1
```

The smoke test verifies the HTTPS certificate, the HTTP-to-HTTPS redirect, unauthenticated API rejection, and authenticated account access.

## URLs and data

- Application (web and API): <https://wealthops-ai.local>
- Development OpenAPI document: <https://wealthops-ai.local/openapi/v1.json>

The seeder requires `DOTNET_ENVIRONMENT=Development` and `Seed:Enabled=true`; it refuses to seed in other environments. Compose `down` preserves named volumes. Do not add `--volumes` unless you intentionally want to erase local PostgreSQL, Kafka, and Airflow data.

Nginx redirects HTTP to HTTPS and proxies `/api` and `/openapi` to the backend over the private Compose network. PostgreSQL, Kafka, and optional Airflow are separate local development endpoints, bound to loopback and not routed through the browser-facing HTTPS edge.

Production is intended for Kubernetes on AWS EKS, but deployment manifests and AWS integrations are future work.

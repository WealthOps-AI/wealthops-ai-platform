# Getting Started on Linux and macOS

## Prerequisites

- Docker Engine on Linux, or Docker Desktop on macOS, with Docker Compose v2.
- Bash, `curl`, and [mkcert](https://github.com/FiloSottile/mkcert) for local TLS.
- No host-installed .NET, Node.js, PostgreSQL, Kafka, or Airflow is needed for the Compose workflow.

The local environment file contains synthetic development values. Keep your `.env` local and never reuse these values in a deployed environment.

On Apple Silicon Macs, Docker Desktop can run ARM64-compatible images natively and emulate images available only for another architecture; emulation may be slower, especially for the optional full profile.

## Check out the repositories

The platform Compose file builds the backend and web images and mounts pipeline DAGs from sibling repositories. In a parent workspace directory, clone the four repositories with their expected folder names:

```sh
git clone https://github.com/WealthOps-AI/wealthops-ai-platform.git
git clone https://github.com/WealthOps-AI/wealthops-ai-be.git
git clone https://github.com/WealthOps-AI/wealthops-ai-web.git
git clone https://github.com/WealthOps-AI/wealthops-ai-pipelines.git
```

Run the commands below from that parent workspace directory.

## Configure local DNS and TLS

Add this entry to `/etc/hosts` using an editor with administrator privileges:

```text
127.0.0.1 wealthops-ai.local
```

The `.local` suffix is also used by multicast DNS and can conflict with some resolvers. If the hosts entry is not honored, resolve the conflict in your local resolver before continuing; the certificate and proxy configuration are specifically set up for `wealthops-ai.local`.

Install mkcert using its official instructions, then install its local development CA and create a certificate:

```sh
bash ./wealthops-ai-platform/local/scripts/linux-macos/generate-local-certificate.sh
```

The script writes the certificate and private key to the git-ignored `wealthops-ai-platform/local/config/certs/` directory. `mkcert -install` adds the local CA to the current machine's trust store; it may request administrator privileges. Do not share or commit the generated private key.

## Start the core application

From the workspace root, create the local environment file and start the stack:

```sh
cp ./wealthops-ai-platform/local/config/.env.example ./wealthops-ai-platform/local/config/.env
bash ./wealthops-ai-platform/local/scripts/linux-macos/start-local.sh
```

The app applies EF Core migrations and loads deterministic Development seed data on first startup.

To also start the standalone Kafka and Airflow infrastructure containers:

```sh
bash ./wealthops-ai-platform/local/scripts/linux-macos/start-local.sh --full
```

These optional containers are not yet connected to application event processing or data pipelines.

## Verify and operate

Check API authentication and service status, then stop the stack while preserving its data volumes:

```sh
bash ./wealthops-ai-platform/local/scripts/linux-macos/smoke-test.sh
docker compose --env-file ./wealthops-ai-platform/local/config/.env \
  -f ./wealthops-ai-platform/local/compose/compose.yml ps
docker compose --env-file ./wealthops-ai-platform/local/config/.env \
  -f ./wealthops-ai-platform/local/compose/compose.yml down
```

Rerun the idempotent sample-data seed when needed:

```sh
bash ./wealthops-ai-platform/local/scripts/linux-macos/load-sample-data.sh
```

The smoke test verifies the HTTPS certificate, the HTTP-to-HTTPS redirect, unauthenticated API rejection, and authenticated account access.

## URLs and data

- Application (web and API): <https://wealthops-ai.local>
- Development OpenAPI document: <https://wealthops-ai.local/openapi/v1.json>

The seeder requires `DOTNET_ENVIRONMENT=Development` and `Seed:Enabled=true`; it refuses to seed in other environments. Compose `down` preserves named volumes. Do not add `--volumes` unless you intentionally want to erase local PostgreSQL, Kafka, and Airflow data.

Nginx redirects HTTP to HTTPS and proxies `/api` and `/openapi` to the backend over the private Compose network. PostgreSQL, Kafka, and optional Airflow are separate local development endpoints, bound to loopback and not routed through the browser-facing HTTPS edge.

Production is intended for Kubernetes on AWS EKS, but deployment manifests and AWS integrations are future work.

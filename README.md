# wealthops-platform

Local Docker Compose topology and production Kubernetes/AWS deployment ownership. Local Compose is the developer runtime; production is AWS EKS. Kubernetes manifests and Terraform infrastructure are intentionally skeleton-only at this stage.

## Local quick start

1. Ensure Docker Desktop is running (Linux containers) with Compose v2.
2. Copy `local/config/.env.example` to `local/config/.env` from the workspace root.
3. On Windows, run the PowerShell convenience script:

   ```powershell
   Copy-Item .\wealthops-platform\local\config\.env.example .\wealthops-platform\local\config\.env
   .\wealthops-platform\local\scripts\start-local.ps1
   ```

   On macOS, copy the file and start Compose directly in Terminal:

   ```sh
   cp ./wealthops-platform/local/config/.env.example ./wealthops-platform/local/config/.env
   docker compose --env-file ./wealthops-platform/local/config/.env \
     -f ./wealthops-platform/local/compose/compose.yml up --build -d
   ```

4. Open the frontend at `http://localhost:8088`. Kong is reachable at `http://localhost:8000`; the API OpenAPI document is exposed in Development at `/openapi/v1.json`.
5. Choose a synthetic development role to sign in. The dev-token endpoint is disabled outside the Development environment. Run `.\wealthops-platform\local\scripts\smoke-test.ps1` for an API authentication check.

The migrator applies the checked-in EF Core migrations and loads the deterministic sample dataset. Rerun seeding with `.\wealthops-platform\local\scripts\load-sample-data.ps1` on Windows or use `docker compose ... run --rm migrator --seed` on macOS, using the same `.env` and Compose file. The local `.env` is git-ignored; its development key and PostgreSQL credentials must never be reused in deployed environments.

Use `.\wealthops-platform\local\scripts\start-local.ps1 -Full` on Windows or add `--profile full` to the `docker compose up` command on macOS to additionally start Kafka and Airflow; they are not yet integrated with the backend or pipelines. Stop with `docker compose ... down` to preserve data volumes. Do not add `--volumes` unless you intentionally want to erase local data.

## Service topology

Compose includes PostgreSQL, a one-shot database migrator/seeder, the .NET API, Kong, the web UI, Kafka, and an optional Airflow standalone container. Kafka and Airflow currently provide infrastructure skeletons; business consumers and DAG logic remain pending.

Production EKS/IAM/MSK/RDS deployment is not implemented. See `../../specifications/21-local-development-guide.md` and `../../specifications/20-repository-topology.md`.

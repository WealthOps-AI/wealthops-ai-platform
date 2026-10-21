param(
    [switch]$Full
)

$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..\..\..')
try {
    $envFile = '.\local\config\.env'
    $certFile = '.\local\config\certs\wealthops-ai.local.pem'
    $keyFile = '.\local\config\certs\wealthops-ai.local-key.pem'
    if (-not (Test-Path -LiteralPath $envFile)) {
        throw "Local environment file not found: $envFile. Copy .\local\config\.env.example to .\local\config\.env first."
    }
    if (-not (Test-Path -LiteralPath $certFile) -or -not (Test-Path -LiteralPath $keyFile)) {
        throw 'Local TLS certificate not found. Run .\local\scripts\windows\generate-local-certificate.ps1 first.'
    }

    $composeArgs = @('--env-file', $envFile, '-f', '.\local\compose\compose.yml')
    if ($Full) {
        $composeArgs += @('--profile', 'full')
    }

    & docker compose @composeArgs up --build -d
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose failed to start the WealthOps services (exit code $LASTEXITCODE)."
    }

    Write-Output 'WealthOps local services are starting. Check readiness with .\local\scripts\windows\smoke-test.ps1.'
    Write-Output 'Application: https://wealthops-ai.local'
    if ($Full) {
        Write-Output 'Airflow: http://localhost:8080 | Kafka bootstrap: localhost:29092'
    }
}
finally {
    Pop-Location
}

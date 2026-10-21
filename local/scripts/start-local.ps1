param(
    [switch]$Full
)

$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..\..')
try {
    $envFile = '.\local\config\.env'
    if (-not (Test-Path -LiteralPath $envFile)) {
        throw "Local environment file not found: $envFile. Copy .\local\config\.env.example to .\local\config\.env first."
    }

    $composeArgs = @('--env-file', $envFile, '-f', '.\local\compose\compose.yml')
    if ($Full) {
        $composeArgs += @('--profile', 'full')
    }

    & docker compose @composeArgs up --build -d
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose failed to start the WealthOps services (exit code $LASTEXITCODE)."
    }

    Write-Output 'WealthOps local services are starting. Check readiness with smoke-test.ps1.'
    Write-Output 'Web: http://localhost:8088 | Kong: http://localhost:8000'
    if ($Full) {
        Write-Output 'Airflow: http://localhost:8080 | Kafka bootstrap: localhost:29092'
    }
}
finally {
    Pop-Location
}

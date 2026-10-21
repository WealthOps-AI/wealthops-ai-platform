$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..\..\..')
try {
    $envFile = '.\local\config\.env'
    if (-not (Test-Path -LiteralPath $envFile)) {
        throw "Local environment file not found: $envFile. Copy .\local\config\.env.example to .\local\config\.env first."
    }

    & docker compose --env-file $envFile -f .\local\compose\compose.yml run --rm migrator --seed
    if ($LASTEXITCODE -ne 0) {
        throw "The development migrator/seeder failed (exit code $LASTEXITCODE)."
    }
}
finally {
    Pop-Location
}

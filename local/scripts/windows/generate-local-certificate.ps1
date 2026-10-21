$ErrorActionPreference = 'Stop'
$platformDirectory = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$certificateDirectory = Join-Path $platformDirectory 'local\config\certs'

if (-not (Get-Command mkcert -ErrorAction SilentlyContinue)) {
    throw 'mkcert is required. Install mkcert, then rerun this script.'
}

New-Item -ItemType Directory -Force -Path $certificateDirectory | Out-Null
& mkcert -install
if ($LASTEXITCODE -ne 0) {
    throw "mkcert could not install its local CA (exit code $LASTEXITCODE)."
}

$certificateFile = Join-Path $certificateDirectory 'wealthops-ai.local.pem'
$keyFile = Join-Path $certificateDirectory 'wealthops-ai.local-key.pem'
& mkcert -cert-file $certificateFile -key-file $keyFile wealthops-ai.local
if ($LASTEXITCODE -ne 0) {
    throw "mkcert could not create the local certificate (exit code $LASTEXITCODE)."
}

Write-Output "Created a locally trusted certificate for wealthops-ai.local in $certificateDirectory"

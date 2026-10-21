$ErrorActionPreference = 'Stop'
$baseUrl = 'https://wealthops-ai.local'
$httpStatus = & curl.exe --silent --show-error --output NUL --write-out '%{http_code}' --max-redirs 0 'http://wealthops-ai.local/'
if ($LASTEXITCODE -ne 0 -or $httpStatus -ne '308') {
    throw "Expected HTTP to redirect to HTTPS with status 308; received HTTP $httpStatus."
}

try {
    Invoke-WebRequest -Uri "$baseUrl/" -Method Get | Out-Null
    Invoke-WebRequest -Uri "$baseUrl/api/v1/accounts" -Method Get | Out-Null
    throw 'Expected an unauthenticated API request to return HTTP 401.'
}
catch {
    $statusCode = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
    if ($statusCode -ne 401) {
        throw "The unauthenticated API check failed (HTTP $statusCode). Ensure the local stack is healthy."
    }
}

$tokenResponse = Invoke-RestMethod `
    -Uri "$baseUrl/api/v1/auth/dev-token" `
    -Method Post `
    -ContentType 'application/json' `
    -Body (@{ role = 'OperationsAnalyst' } | ConvertTo-Json -Compress)
if ([string]::IsNullOrWhiteSpace($tokenResponse.token)) {
    throw 'The Development token endpoint returned an empty token.'
}

$headers = @{ Authorization = "Bearer $($tokenResponse.token)" }
$accounts = Invoke-RestMethod -Uri "$baseUrl/api/v1/accounts" -Method Get -Headers $headers
if ($null -eq $accounts.items) {
    throw 'The authenticated accounts endpoint did not return the expected page response.'
}

Write-Output "Smoke test passed: trusted HTTPS is available, HTTP redirects to HTTPS, unauthenticated API access is rejected, and authenticated API access returned $($accounts.total) seeded accounts."

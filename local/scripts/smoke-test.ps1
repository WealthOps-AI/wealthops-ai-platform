$ErrorActionPreference = 'Stop'
$baseUrl = 'http://localhost:8000'

try {
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

Write-Output "Smoke test passed: unauthenticated request rejected; authenticated request returned $($accounts.total) seeded accounts."

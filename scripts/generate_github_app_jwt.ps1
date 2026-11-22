#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Generate a short-lived GitHub App JWT (RS256).

.NOTES
  Requires PowerShell 7+ (pwsh) because ImportFromPem is unavailable in Windows PowerShell 5.1.
  Prefer scripts/generate_github_app_jwt.py when possible.

  Env vars:
    GITHUB_APP_CLIENT_ID
    GITHUB_APP_PRIVATE_KEY_PATH
#>

$ErrorActionPreference = "Stop"

$clientId = if ($env:GITHUB_APP_CLIENT_ID) { $env:GITHUB_APP_CLIENT_ID } else { $args[1] }
$privateKeyPath = if ($env:GITHUB_APP_PRIVATE_KEY_PATH) { $env:GITHUB_APP_PRIVATE_KEY_PATH } else { $args[0] }

if (-not $clientId -or -not $privateKeyPath) {
  Write-Error "Set GITHUB_APP_CLIENT_ID and GITHUB_APP_PRIVATE_KEY_PATH, or pass: .\generate_github_app_jwt.ps1 <pem> <client_id>"
}

if (-not (Test-Path $privateKeyPath)) {
  Write-Error "Private key not found: $privateKeyPath"
}

function ConvertTo-Base64Url([byte[]]$bytes) {
  [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

$headerJson = '{"alg":"RS256","typ":"JWT"}'
$now = [System.DateTimeOffset]::UtcNow
$payloadObj = @{
  iat = $now.AddSeconds(-60).ToUnixTimeSeconds()
  exp = $now.AddMinutes(10).ToUnixTimeSeconds()
  iss = $clientId
}
$payloadJson = ($payloadObj | ConvertTo-Json -Compress)

$header = ConvertTo-Base64Url([System.Text.Encoding]::UTF8.GetBytes($headerJson))
$payload = ConvertTo-Base64Url([System.Text.Encoding]::UTF8.GetBytes($payloadJson))

$rsa = [System.Security.Cryptography.RSA]::Create()
try {
  $rsa.ImportFromPem((Get-Content $privateKeyPath -Raw))
} catch {
  Write-Error "ImportFromPem failed. Use PowerShell 7+ (pwsh) or the Python script instead. $_"
}

$signingInput = [System.Text.Encoding]::UTF8.GetBytes("$header.$payload")
$signatureBytes = $rsa.SignData(
  $signingInput,
  [System.Security.Cryptography.HashAlgorithmName]::SHA256,
  [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
)
$signature = ConvertTo-Base64Url($signatureBytes)

Write-Output "$header.$payload.$signature"

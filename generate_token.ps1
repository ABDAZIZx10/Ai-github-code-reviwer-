#!/usr/bin/env pwsh
# Compatibility wrapper — prefer scripts/generate_github_app_jwt.py
# Requires PowerShell 7+ if you use the .ps1 implementation.
$ErrorActionPreference = "Stop"
& "$PSScriptRoot\scripts\generate_github_app_jwt.ps1" @args

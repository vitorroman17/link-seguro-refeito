$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot

Write-Host "Frontend em http://localhost:5500"
python -m http.server 5500

Pop-Location

$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot

if (-not (Test-Path ".\.venv")) { python -m venv .venv }
& .\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt

$env:ALLOWED_ORIGINS = "*"
# (opcional) habilitar VirusTotal:
# $env:VT_API_KEY = "SUA_CHAVE_DO_VIRUSTOTAL"

Write-Host "Backend em http://127.0.0.1:8000"
# espelha no console e grava em backend\server.log
python -m uvicorn app:app --host 127.0.0.1 --port 8000 --reload 2>&1 |
  Tee-Object -FilePath "$PSScriptRoot\server.log" -Append

Pop-Location

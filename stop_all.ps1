# STOP: encerra BEC + FRONT + TÃšNEL  | PowerShell 5
$ErrorActionPreference = "SilentlyContinue"

$root   = "C:\link-seguro-refeito"
$piddir = Join-Path $root "reports"
$uvpid  = Join-Path $piddir "uvicorn.pid"
$fepid  = Join-Path $piddir "frontend.pid"
$cfpid  = Join-Path $piddir "cloudflared.pid"

function Stop-ByPidFile($pidfile, $label){
  if (Test-Path $pidfile){
    $pidValue = (Get-Content -Raw $pidfile | ForEach-Object { $_.Trim() } | Select-Object -First 1)
    if ($pidValue -and ($pidValue -as [int])) {
      try { Get-Process -Id $pidValue -ErrorAction Stop | Stop-Process -Force; Write-Host "Parado PID $pidValue ($label)" -ForegroundColor Yellow }
      catch { Write-Host "PID $pidValue nÃ£o encontrado ($label). Limpando pidfile." -ForegroundColor DarkYellow }
    }
    Remove-Item $pidfile -Force -ErrorAction SilentlyContinue
  }
}
function Stop-ByPort($port){
  try {
    $procs = Get-NetTCPConnection -State Listen | Where-Object {$_.LocalPort -eq $port} | Select-Object -ExpandProperty OwningProcess -Unique
    foreach($p in $procs){ try{ Stop-Process -Id $p -Force }catch{} }
  } catch {}
}
function Stop-ByPattern($pattern){
  try {
    $procs = Get-WmiObject Win32_Process | Where-Object { $_.Name -match $pattern -or $_.CommandLine -match $pattern }
    foreach($p in $procs){ try{ Stop-Process -Id $p.ProcessId -Force }catch{} }
  } catch {}
}

# 1) pidfiles
Stop-ByPidFile $uvpid "uvicorn"
Stop-ByPidFile $fepid "frontend"
Stop-ByPidFile $cfpid "cloudflared"

# 2) portas padrÃ£o
Stop-ByPort 8000    # backend
Stop-ByPort 3000    # front (React)
Stop-ByPort 5173    # front (Vite)

# 3) padrÃµes de processo
Stop-ByPattern 'uvicorn'
Stop-ByPattern 'cloudflared'
Stop-ByPattern 'vite|react-scripts|next|npm|node'

# 4) varredura final de seguranÃ§a
Get-Process python,cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "Todos os processos alvo foram encerrados (ou jÃ¡ estavam parados)." -ForegroundColor Green


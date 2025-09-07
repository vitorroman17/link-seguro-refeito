# START: BEC (backend) + FRONT + TÃšNEL (cloudflared)  | PowerShell 5
$ErrorActionPreference = "Continue"

# --- Caminhos/base ---
$root = "C:\link-seguro-refeito"
$bkDir = Join-Path $root "backend"
$feDir = Join-Path $root "frontend"
$feZip = Join-Path $root "frontend.zip"

# --- Backend (Uvicorn/FastAPI) ---
$py   = Join-Path $root ".venv\Scripts\python.exe"
$uuid = "66ff7d96-b54e-4cac-ab63-29ab8a448309"               # ajuste se mudar de tÃºnel
$cfg  = "C:\Users\Noeli\.cloudflared\config.yml"             # ajuste se mudar de usuÃ¡rio/arquivo
$cf   = "C:\Program Files (x86)\cloudflared\cloudflared.exe"

# --- Logs/PIDs ---
$logDir = Join-Path $root "reports\logs"; New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$piddir = Join-Path $root "reports";      New-Item -ItemType Directory -Path $piddir -Force | Out-Null
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$uvOut = Join-Path $logDir ("uvicorn-{0}.out.log" -f $ts)
$uvErr = Join-Path $logDir ("uvicorn-{0}.err.log" -f $ts)
$feOut = Join-Path $logDir ("frontend-{0}.out.log" -f $ts)
$feErr = Join-Path $logDir ("frontend-{0}.err.log" -f $ts)
$cfOut = Join-Path $logDir ("cloudflared-{0}.out.log" -f $ts)
$cfErr = Join-Path $logDir ("cloudflared-{0}.err.log" -f $ts)
$uvpid = Join-Path $piddir "uvicorn.pid"
$fepid = Join-Path $piddir "frontend.pid"
$cfpid = Join-Path $piddir "cloudflared.pid"

function Find-Node {
  $n = $null; try { $n = Get-Command node -ErrorAction SilentlyContinue } catch {}
  if($n -and $n.Source){ return $n.Source }
  foreach($p in @("C:\Program Files\nodejs\node.exe","C:\Program Files (x86)\nodejs\node.exe")){ if(Test-Path $p){ return $p } }
  return $null
}
function Find-NpmCmd {
  $n = $null; try { $n = Get-Command npm -ErrorAction SilentlyContinue } catch {}
  if($n -and $n.Source){ return $n.Source }   # geralmente npm.cmd
  foreach($p in @("C:\Program Files\nodejs\npm.cmd","C:\Program Files (x86)\nodejs\npm.cmd")){ if(Test-Path $p){ return $p } }
  return $null
}

# ===================== FRONT (autodetect) =====================
$startFrontend       = $false   # via npm
$startFrontendStatic = $false   # via python -m http.server
$nodePath = Find-Node
$npmCmd   = Find-NpmCmd
$feScript = $null
$fePort   = $null

# Se nÃ£o existir pasta frontend mas existir zip, descompacta
if( (-not (Test-Path $feDir)) -and (Test-Path $feZip) ){
  try {
    Expand-Archive -Path $feZip -DestinationPath $feDir -Force
    Write-Host "frontend.zip descompactado em $feDir" -ForegroundColor Cyan
  } catch {
    Write-Host "Falha ao descompactar ${feZip}: $($_.Exception.Message)" -ForegroundColor Red
  }
}

# Tenta achar package.json em qualquer subpasta
$pkgHit = $null
try { $pkgHit = Get-ChildItem -Path $feDir -Recurse -Filter package.json -File -ErrorAction SilentlyContinue | Select-Object -First 1 } catch {}
if ($pkgHit) { $feDir = Split-Path -Parent $pkgHit.FullName }

$pkgPath = Join-Path $feDir "package.json"
if ( (Test-Path $pkgPath) -and $nodePath -and $npmCmd ){
  try {
    $pkg = Get-Content -Raw $pkgPath | ConvertFrom-Json
    if ($pkg.scripts -and $pkg.scripts.dev)        { $feScript = "dev";   $fePort = 5173 }
    elseif ($pkg.scripts -and $pkg.scripts.start)  { $feScript = "start"; $fePort = 3000 }
  } catch {}
}
if ($feScript) {
  $startFrontend = $true
} else {
  # Sem package.json: procurar index.html para servir estÃ¡tico
  $idx = $null
  try { $idx = Get-ChildItem -Path $feDir -Recurse -Filter index.html -File -ErrorAction SilentlyContinue | Select-Object -First 1 } catch {}
  if ($idx) {
    $feDir = Split-Path -Parent $idx.FullName
    $startFrontendStatic = $true
    $fePort = 5173
  }
}

# ===================== BACKEND (obrigatÃ³rio) ==================
# Detecta mÃ³dulo FastAPI
$mod = $null
if (Test-Path (Join-Path $bkDir "app.py"))      { $mod = "backend.app:app" }
elseif (Test-Path (Join-Path $bkDir "main.py")) { $mod = "backend.main:app" }
else {
  $cand = Get-ChildItem -Recurse -Filter *.py $bkDir -ErrorAction SilentlyContinue |
          Where-Object { $_.FullName -notmatch '\\\.venv\\' } |
          ForEach-Object { try { if(Select-String -Path $_.FullName -SimpleMatch 'FastAPI(' -Quiet){ $_.FullName } } catch {} } |
          Select-Object -First 1
  if ($cand) {
    $rel = $cand.Replace((Resolve-Path $bkDir).Path,'').Trim('\').Replace('\','/')
    $mod = 'backend.' + ($rel -replace '\.py$','' -replace '/','.') + ':app'
  }
}

# PrÃ©-checagens
if (-not (Test-Path $py))  { Write-Host "Python da venv nÃ£o encontrado: $py" -ForegroundColor Red; exit 1 }
if (-not $mod)             { Write-Host "NÃ£o achei mÃ³dulo FastAPI em $bkDir" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $cf))  { Write-Host "cloudflared nÃ£o encontrado: $cf" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $cfg)) { Write-Host "config.yml nÃ£o encontrado: $cfg" -ForegroundColor Red; exit 1 }

# ===================== START =====================

# Uvicorn (anti-duplicado na 8000)
$listenPids = @()
try { $listenPids = Get-NetTCPConnection -State Listen | Where-Object LocalPort -eq 8000 | Select-Object -Expand OwningProcess -Unique } catch {}
if ($listenPids -and $listenPids.Count -gt 0) {
  $keep = $listenPids | Select-Object -First 1
  Write-Host ("JÃ¡ existe backend ouvindo na 8000 (PID {0}); nÃ£o vou iniciar outro." -f $keep) -ForegroundColor Yellow
  $keep | Out-File -Encoding ascii $uvpid
} else {
  $uvArgs = @("-m","uvicorn",$mod,"--host","127.0.0.1","--port","8000","--log-level","info","--proxy-headers")
  $uv = Start-Process -FilePath $py -ArgumentList $uvArgs -WorkingDirectory $root `
          -WindowStyle Hidden -PassThru `
          -RedirectStandardOutput $uvOut -RedirectStandardError $uvErr
  $uv.Id | Out-File -Encoding ascii $uvpid
}

# FRONT (npm) ou estÃ¡tico
if ($startFrontend) {
  $nm = Join-Path $feDir "node_modules"
  if (-not (Test-Path $nm)) {
    Write-Host "Instalando dependÃªncias do FRONT..." -ForegroundColor Cyan
    $null = Start-Process -FilePath $npmCmd -ArgumentList @("install") -WorkingDirectory $feDir -Wait -PassThru `
              -RedirectStandardOutput $feOut -RedirectStandardError $feErr
  }
  if ($feScript -eq "dev" -and $fePort) { $feArgs = @("run","dev","--","--port",$fePort) } else { $feArgs = @("start") }
  $fe = Start-Process -FilePath $npmCmd -ArgumentList $feArgs -WorkingDirectory $feDir `
          -WindowStyle Hidden -PassThru `
          -RedirectStandardOutput $feOut -RedirectStandardError $feErr
  $fe.Id | Out-File -Encoding ascii $fepid
} elseif ($startFrontendStatic) {
  $httpArgs = @("-m","http.server",$fePort,"--bind","127.0.0.1")
  $fe = Start-Process -FilePath $py -ArgumentList $httpArgs -WorkingDirectory $feDir `
          -WindowStyle Hidden -PassThru `
          -RedirectStandardOutput $feOut -RedirectStandardError $feErr
  $fe.Id | Out-File -Encoding ascii $fepid
}

# Cloudflared (anti-duplicado)
$cfExisting = Get-Process cloudflared -ErrorAction SilentlyContinue
if ($cfExisting) {
  Write-Host ("cloudflared jÃ¡ estÃ¡ rodando (PID {0}); nÃ£o vou iniciar outro." -f $cfExisting.Id) -ForegroundColor Yellow
  $cfExisting.Id | Out-File -Encoding ascii $cfpid
} else {
  $cfArgs = @("tunnel","--config",$cfg,"run",$uuid)
  $cfp = Start-Process -FilePath $cf -ArgumentList $cfArgs -WorkingDirectory $root `
          -WindowStyle Hidden -PassThru `
          -RedirectStandardOutput $cfOut -RedirectStandardError $cfErr
  $cfp.Id | Out-File -Encoding ascii $cfpid
}

# Resumo
Write-Host "Iniciado." -ForegroundColor Green

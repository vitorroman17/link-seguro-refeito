# check-linkseguro.ps1 — compatível com Windows PowerShell 5
$ErrorActionPreference = "Continue"

# Defaults (ajuste se quiser)
$BackendLocal   = "http://127.0.0.1:8000"
$PublicHost     = "app.vitorroman.com.br"
$FrontPorts     = @()
$TunnelUuidPref = "66ff7d96-b54e-4cac-ab63-29ab8a448309"
$CfCredDir      = "C:\Users\Noeli\.cloudflared"

function Find-CloudflaredPath {
  $c = $null; try { $c = Get-Command cloudflared -ErrorAction SilentlyContinue } catch {}
  if ($c -and $c.Source) { return $c.Source }
  foreach($p in @(
    "C:\Program Files\Cloudflared\cloudflared.exe",
    "C:\Program Files (x86)\cloudflared\cloudflared.exe"
  )){ if(Test-Path $p){ return $p } }
  return $null
}

function HttpCheck($url, [int]$timeoutSec=5){
  try{ $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec $timeoutSec -Uri $url
       return @{ ok=$true; status=$r.StatusCode; url=$url } }
  catch{ $st=$null; try{$st=$_.Exception.Response.StatusCode.value__}catch{}
         return @{ ok=$false; status=$st; url=$url; error=$_.Exception.Message } }
}

function PortListen($p){ try{ (Get-NetTCPConnection -State Listen | Where-Object {$_.LocalPort -eq $p}).Count -gt 0 }catch{ $false } }
function Pass($b){ if($b){"PASS"}else{"FAIL"} }
function ShowStatus($r){ if(-not $r){"N/A"} elseif($r.ok){$r.status}else{ if($r.status){$r.status}else{$r.error} } }

# Caminhos de relatório
$root = "C:\link-seguro-refeito"
$now  = Get-Date -Format "yyyyMMdd-HHmmss"
$rep  = Join-Path $root "reports"; New-Item -ItemType Directory -Path $rep -Force | Out-Null
$TXT  = Join-Path $rep "healthcheck-$now.txt"
$JSON = Join-Path $rep "healthcheck-$now.json"

# --- BACKEND LOCAL ---
$bkDocs   = HttpCheck ($BackendLocal.TrimEnd('/') + "/docs") 5
$bkHealth = HttpCheck ($BackendLocal.TrimEnd('/') + "/health") 3
$bkPort   = (New-Object Uri($BackendLocal)).Port; if(-not $bkPort){ $bkPort = 80 }
$bkListen = PortListen $bkPort
$back_ok  = ($bkDocs.ok -or $bkHealth.ok -or $bkListen)

# --- FRONTEND LOCAL ---
$frontChecks=@()
foreach($p in $FrontPorts){
  $fc = HttpCheck ("http://127.0.0.1:{0}" -f $p) 3
  $fl = PortListen $p
  $frontChecks += @{ port=$p; http=$fc; listening=$fl }
}
$front_ok = ($FrontPorts.Count -eq 0) -or (( $frontChecks | Where-Object { # check-linkseguro.ps1 — compatível com Windows PowerShell 5
$ErrorActionPreference = "Continue"

# Defaults (ajuste se quiser)
$BackendLocal   = "http://127.0.0.1:8000"
$PublicHost     = "app.vitorroman.com.br"
$FrontPorts     = @()
$TunnelUuidPref = "66ff7d96-b54e-4cac-ab63-29ab8a448309"
$CfCredDir      = "C:\Users\Noeli\.cloudflared"

function Find-CloudflaredPath {
  $c = $null; try { $c = Get-Command cloudflared -ErrorAction SilentlyContinue } catch {}
  if ($c -and $c.Source) { return $c.Source }
  foreach($p in @(
    "C:\Program Files\Cloudflared\cloudflared.exe",
    "C:\Program Files (x86)\cloudflared\cloudflared.exe"
  )){ if(Test-Path $p){ return $p } }
  return $null
}

function HttpCheck($url, [int]$timeoutSec=5){
  try{ $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec $timeoutSec -Uri $url
       return @{ ok=$true; status=$r.StatusCode; url=$url } }
  catch{ $st=$null; try{$st=$_.Exception.Response.StatusCode.value__}catch{}
         return @{ ok=$false; status=$st; url=$url; error=$_.Exception.Message } }
}

function PortListen($p){ try{ (Get-NetTCPConnection -State Listen | Where-Object {$_.LocalPort -eq $p}).Count -gt 0 }catch{ $false } }
function Pass($b){ if($b){"PASS"}else{"FAIL"} }
function ShowStatus($r){ if(-not $r){"N/A"} elseif($r.ok){$r.status}else{ if($r.status){$r.status}else{$r.error} } }

# Caminhos de relatório
$root = "C:\link-seguro-refeito"
$now  = Get-Date -Format "yyyyMMdd-HHmmss"
$rep  = Join-Path $root "reports"; New-Item -ItemType Directory -Path $rep -Force | Out-Null
$TXT  = Join-Path $rep "healthcheck-$now.txt"
$JSON = Join-Path $rep "healthcheck-$now.json"

# --- BACKEND LOCAL ---
$bkDocs   = HttpCheck ($BackendLocal.TrimEnd('/') + "/docs") 5
$bkHealth = HttpCheck ($BackendLocal.TrimEnd('/') + "/health") 3
$bkPort   = (New-Object Uri($BackendLocal)).Port; if(-not $bkPort){ $bkPort = 80 }
$bkListen = PortListen $bkPort
$back_ok  = ($bkDocs.ok -or $bkHealth.ok -or $bkListen)

# --- FRONTEND LOCAL ---
$frontChecks=@()
foreach($p in $FrontPorts){
  $fc = HttpCheck ("http://127.0.0.1:{0}" -f $p) 3
  $fl = PortListen $p
  $frontChecks += @{ port=$p; http=$fc; listening=$fl }
}
$front_ok = (($frontChecks | Where-Object { $_.http.ok -or $_.listening }).Count -gt 0)
$frontendSummary = Pass $front_ok

# --- TÚNEL / CLOUDFLARED ---
$cfPath    = Find-CloudflaredPath
$cfExists  = if($cfPath){ Test-Path $cfPath } else { $false }
$cfRunning = (Get-Process cloudflared -ErrorAction SilentlyContinue).Count -gt 0
$cfgYml    = Join-Path $CfCredDir "config.yml"
$cfgExists = Test-Path $cfgYml
$credFiles = @(); if(Test-Path $CfCredDir){ $credFiles = Get-ChildItem $CfCredDir -Filter *.json -File -ErrorAction SilentlyContinue }
$credUse   = $null
if($credFiles){ $credUse = ($credFiles | Where-Object { $_.Name -like "$TunnelUuidPref*.json" } | Select-Object -First 1) }
if(-not $credUse -and $credFiles){ $credUse = $credFiles | Select-Object -First 1 }
$tunnelUuid = $null
if($credUse){ try{ $tunnelUuid = (Get-Content -Raw $credUse.FullName | ConvertFrom-Json).TunnelID }catch{} }
if(-not $tunnelUuid){ $tunnelUuid = $TunnelUuidPref }
$tunnel_ok = ($cfExists -and $cfRunning -and $credUse)

# --- DNS / PÚBLICO ---
$dnsCname=$null;$dnsA=$null;$dnsAAAA=$null
try{ $tmp = Resolve-DnsName $PublicHost -Type CNAME -Server 1.1.1.1 -ErrorAction Stop; if($tmp){ $dnsCname = $tmp.NameHost } }catch{}
try{ $dnsA     = Resolve-DnsName $PublicHost -Type A     -Server 1.1.1.1 -ErrorAction SilentlyContinue }catch{}
try{ $dnsAAAA  = Resolve-DnsName $PublicHost -Type AAAA  -Server 1.1.1.1 -ErrorAction SilentlyContinue }catch{}
$cnameExpected = $null; if($tunnelUuid){ $cnameExpected = "$tunnelUuid.cfargotunnel.com" }
$dnsOk = $false
if($dnsCname -and $cnameExpected){ $dnsOk = ($dnsCname -like "*$cnameExpected") -and (-not $dnsA) -and (-not $dnsAAAA) }
$pubDocs = HttpCheck ("https://{0}/docs" -f $PublicHost) 8
$public_ok = ($pubDocs.ok -and $pubDocs.status -eq 200)

# --- RELATÓRIO (objeto) ---
$credUsedPath = if($credUse){ $credUse.FullName } else { $null }
$report = [ordered]@{
  timestamp = $now
  backend   = [ordered]@{
    local_url      = $BackendLocal
    docs           = $bkDocs
    health         = $bkHealth
    port_listening = $bkListen
    summary        = (Pass $back_ok)
  }
  frontend  = @([ordered]@{ ports=$FrontPorts; checks=$frontChecks; summary=$frontendSummary })
  tunnel    = [ordered]@{
    cloudflared_path    = $cfPath
    cloudflared_running = $cfRunning
    credentials_dir     = $CfCredDir
    credential_used     = $credUsedPath
    tunnel_uuid         = $tunnelUuid
    config_yml          = @{ exists=$cfgExists; path=$cfgYml }
    summary             = (Pass $tunnel_ok)
  }
  public    = [ordered]@{
    hostname       = $PublicHost
    cname          = $dnsCname
    cname_expected = $cnameExpected
    has_A_or_AAAA  = [bool]($dnsA -or $dnsAAAA)
    https_docs     = $pubDocs
    dns_ok         = (Pass $dnsOk)
    summary        = (Pass $public_ok)
  }
}

# --- RELATÓRIO (texto) ---
$credUsedText = if($credUsedPath){ $credUsedPath } else { "(não definida)" }
$cnameText    = if($dnsCname){ $dnsCname } else { "(nenhum)" }
$cnameExpText = if($cnameExpected){ $cnameExpected } else { "(n/a)" }

$lines=@()
$lines += "=== LINK SEGURO :: HEALTCHECK $($report.timestamp) ==="
$lines += ""
$lines += "[Backend]"
$lines += ("  Local: {0}" -f $report.backend.local_url)
$lines += ("  /docs -> {0}"   -f (ShowStatus $report.backend.docs))
$lines += ("  /health -> {0}" -f (ShowStatus $report.backend.health))
$lines += ("  Porta ouvindo -> {0}" -f $report.backend.port_listening)
$lines += ("  => {0}" -f $report.backend.summary)
$lines += ""
$lines += "[Frontend]"
foreach($c in $frontChecks){ $lines += ("  Porta {0}: listening={1} http={2}" -f $c.port, $c.listening, (ShowStatus $c.http)) }
$lines += ("  => {0}" -f $frontendSummary)
$lines += ""
$lines += "[Tunnel]"
$lines += ("  cloudflared: {0} (running={1})" -f $report.tunnel.cloudflared_path, $report.tunnel.cloudflared_running)
$lines += ("  cred dir: {0}" -f $report.tunnel.credentials_dir)
$lines += ("  cred usada: {0}" -f $credUsedText)
$lines += ("  tunnel UUID: {0}" -f $report.tunnel.tunnel_uuid)
$lines += ("  config.yml: exists={0} path={1}" -f $report.tunnel.config_yml.exists, $report.tunnel.config_yml.path)
$lines += ("  => {0}" -f $report.tunnel.summary)
$lines += ""
$lines += "[Público]"
$lines += ("  hostname: {0}" -f $report.public.hostname)
$lines += ("  CNAME: {0}" -f $cnameText)
$lines += ("  esperado: {0}" -f $cnameExpText)
$lines += ("  A/AAAA?: {0}" -f $report.public.has_A_or_AAAA)
$lines += ("  https /docs -> {0}" -f (ShowStatus $report.public.https_docs))
$lines += ("  DNS OK? => {0}" -f $report.public.dns_ok)
$lines += ("  => {0}" -f $report.public.summary)
$lines += ""
$lines += "Relatório salvo em:"
$lines += "  $TXT"
$lines += "  $JSON"

$lines -join "`r`n" | Set-Content -Encoding UTF8 $TXT
$report | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 $JSON

Write-Host "`n--- RESUMO ---`n" -ForegroundColor Cyan
Get-Content $TXT | Select-Object -First 60
.http.ok -or # check-linkseguro.ps1 — compatível com Windows PowerShell 5
$ErrorActionPreference = "Continue"

# Defaults (ajuste se quiser)
$BackendLocal   = "http://127.0.0.1:8000"
$PublicHost     = "app.vitorroman.com.br"
$FrontPorts     = @()
$TunnelUuidPref = "66ff7d96-b54e-4cac-ab63-29ab8a448309"
$CfCredDir      = "C:\Users\Noeli\.cloudflared"

function Find-CloudflaredPath {
  $c = $null; try { $c = Get-Command cloudflared -ErrorAction SilentlyContinue } catch {}
  if ($c -and $c.Source) { return $c.Source }
  foreach($p in @(
    "C:\Program Files\Cloudflared\cloudflared.exe",
    "C:\Program Files (x86)\cloudflared\cloudflared.exe"
  )){ if(Test-Path $p){ return $p } }
  return $null
}

function HttpCheck($url, [int]$timeoutSec=5){
  try{ $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec $timeoutSec -Uri $url
       return @{ ok=$true; status=$r.StatusCode; url=$url } }
  catch{ $st=$null; try{$st=$_.Exception.Response.StatusCode.value__}catch{}
         return @{ ok=$false; status=$st; url=$url; error=$_.Exception.Message } }
}

function PortListen($p){ try{ (Get-NetTCPConnection -State Listen | Where-Object {$_.LocalPort -eq $p}).Count -gt 0 }catch{ $false } }
function Pass($b){ if($b){"PASS"}else{"FAIL"} }
function ShowStatus($r){ if(-not $r){"N/A"} elseif($r.ok){$r.status}else{ if($r.status){$r.status}else{$r.error} } }

# Caminhos de relatório
$root = "C:\link-seguro-refeito"
$now  = Get-Date -Format "yyyyMMdd-HHmmss"
$rep  = Join-Path $root "reports"; New-Item -ItemType Directory -Path $rep -Force | Out-Null
$TXT  = Join-Path $rep "healthcheck-$now.txt"
$JSON = Join-Path $rep "healthcheck-$now.json"

# --- BACKEND LOCAL ---
$bkDocs   = HttpCheck ($BackendLocal.TrimEnd('/') + "/docs") 5
$bkHealth = HttpCheck ($BackendLocal.TrimEnd('/') + "/health") 3
$bkPort   = (New-Object Uri($BackendLocal)).Port; if(-not $bkPort){ $bkPort = 80 }
$bkListen = PortListen $bkPort
$back_ok  = ($bkDocs.ok -or $bkHealth.ok -or $bkListen)

# --- FRONTEND LOCAL ---
$frontChecks=@()
foreach($p in $FrontPorts){
  $fc = HttpCheck ("http://127.0.0.1:{0}" -f $p) 3
  $fl = PortListen $p
  $frontChecks += @{ port=$p; http=$fc; listening=$fl }
}
$front_ok = (($frontChecks | Where-Object { $_.http.ok -or $_.listening }).Count -gt 0)
$frontendSummary = Pass $front_ok

# --- TÚNEL / CLOUDFLARED ---
$cfPath    = Find-CloudflaredPath
$cfExists  = if($cfPath){ Test-Path $cfPath } else { $false }
$cfRunning = (Get-Process cloudflared -ErrorAction SilentlyContinue).Count -gt 0
$cfgYml    = Join-Path $CfCredDir "config.yml"
$cfgExists = Test-Path $cfgYml
$credFiles = @(); if(Test-Path $CfCredDir){ $credFiles = Get-ChildItem $CfCredDir -Filter *.json -File -ErrorAction SilentlyContinue }
$credUse   = $null
if($credFiles){ $credUse = ($credFiles | Where-Object { $_.Name -like "$TunnelUuidPref*.json" } | Select-Object -First 1) }
if(-not $credUse -and $credFiles){ $credUse = $credFiles | Select-Object -First 1 }
$tunnelUuid = $null
if($credUse){ try{ $tunnelUuid = (Get-Content -Raw $credUse.FullName | ConvertFrom-Json).TunnelID }catch{} }
if(-not $tunnelUuid){ $tunnelUuid = $TunnelUuidPref }
$tunnel_ok = ($cfExists -and $cfRunning -and $credUse)

# --- DNS / PÚBLICO ---
$dnsCname=$null;$dnsA=$null;$dnsAAAA=$null
try{ $tmp = Resolve-DnsName $PublicHost -Type CNAME -Server 1.1.1.1 -ErrorAction Stop; if($tmp){ $dnsCname = $tmp.NameHost } }catch{}
try{ $dnsA     = Resolve-DnsName $PublicHost -Type A     -Server 1.1.1.1 -ErrorAction SilentlyContinue }catch{}
try{ $dnsAAAA  = Resolve-DnsName $PublicHost -Type AAAA  -Server 1.1.1.1 -ErrorAction SilentlyContinue }catch{}
$cnameExpected = $null; if($tunnelUuid){ $cnameExpected = "$tunnelUuid.cfargotunnel.com" }
$dnsOk = $false
if($dnsCname -and $cnameExpected){ $dnsOk = ($dnsCname -like "*$cnameExpected") -and (-not $dnsA) -and (-not $dnsAAAA) }
$pubDocs = HttpCheck ("https://{0}/docs" -f $PublicHost) 8
$public_ok = ($pubDocs.ok -and $pubDocs.status -eq 200)

# --- RELATÓRIO (objeto) ---
$credUsedPath = if($credUse){ $credUse.FullName } else { $null }
$report = [ordered]@{
  timestamp = $now
  backend   = [ordered]@{
    local_url      = $BackendLocal
    docs           = $bkDocs
    health         = $bkHealth
    port_listening = $bkListen
    summary        = (Pass $back_ok)
  }
  frontend  = @([ordered]@{ ports=$FrontPorts; checks=$frontChecks; summary=$frontendSummary })
  tunnel    = [ordered]@{
    cloudflared_path    = $cfPath
    cloudflared_running = $cfRunning
    credentials_dir     = $CfCredDir
    credential_used     = $credUsedPath
    tunnel_uuid         = $tunnelUuid
    config_yml          = @{ exists=$cfgExists; path=$cfgYml }
    summary             = (Pass $tunnel_ok)
  }
  public    = [ordered]@{
    hostname       = $PublicHost
    cname          = $dnsCname
    cname_expected = $cnameExpected
    has_A_or_AAAA  = [bool]($dnsA -or $dnsAAAA)
    https_docs     = $pubDocs
    dns_ok         = (Pass $dnsOk)
    summary        = (Pass $public_ok)
  }
}

# --- RELATÓRIO (texto) ---
$credUsedText = if($credUsedPath){ $credUsedPath } else { "(não definida)" }
$cnameText    = if($dnsCname){ $dnsCname } else { "(nenhum)" }
$cnameExpText = if($cnameExpected){ $cnameExpected } else { "(n/a)" }

$lines=@()
$lines += "=== LINK SEGURO :: HEALTCHECK $($report.timestamp) ==="
$lines += ""
$lines += "[Backend]"
$lines += ("  Local: {0}" -f $report.backend.local_url)
$lines += ("  /docs -> {0}"   -f (ShowStatus $report.backend.docs))
$lines += ("  /health -> {0}" -f (ShowStatus $report.backend.health))
$lines += ("  Porta ouvindo -> {0}" -f $report.backend.port_listening)
$lines += ("  => {0}" -f $report.backend.summary)
$lines += ""
$lines += "[Frontend]"
foreach($c in $frontChecks){ $lines += ("  Porta {0}: listening={1} http={2}" -f $c.port, $c.listening, (ShowStatus $c.http)) }
$lines += ("  => {0}" -f $frontendSummary)
$lines += ""
$lines += "[Tunnel]"
$lines += ("  cloudflared: {0} (running={1})" -f $report.tunnel.cloudflared_path, $report.tunnel.cloudflared_running)
$lines += ("  cred dir: {0}" -f $report.tunnel.credentials_dir)
$lines += ("  cred usada: {0}" -f $credUsedText)
$lines += ("  tunnel UUID: {0}" -f $report.tunnel.tunnel_uuid)
$lines += ("  config.yml: exists={0} path={1}" -f $report.tunnel.config_yml.exists, $report.tunnel.config_yml.path)
$lines += ("  => {0}" -f $report.tunnel.summary)
$lines += ""
$lines += "[Público]"
$lines += ("  hostname: {0}" -f $report.public.hostname)
$lines += ("  CNAME: {0}" -f $cnameText)
$lines += ("  esperado: {0}" -f $cnameExpText)
$lines += ("  A/AAAA?: {0}" -f $report.public.has_A_or_AAAA)
$lines += ("  https /docs -> {0}" -f (ShowStatus $report.public.https_docs))
$lines += ("  DNS OK? => {0}" -f $report.public.dns_ok)
$lines += ("  => {0}" -f $report.public.summary)
$lines += ""
$lines += "Relatório salvo em:"
$lines += "  $TXT"
$lines += "  $JSON"

$lines -join "`r`n" | Set-Content -Encoding UTF8 $TXT
$report | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 $JSON

Write-Host "`n--- RESUMO ---`n" -ForegroundColor Cyan
Get-Content $TXT | Select-Object -First 60
.listening } ).Count -gt 0)
$frontendSummary = Pass $front_ok

# --- TÚNEL / CLOUDFLARED ---
$cfPath    = Find-CloudflaredPath
$cfExists  = if($cfPath){ Test-Path $cfPath } else { $false }
$cfRunning = (Get-Process cloudflared -ErrorAction SilentlyContinue).Count -gt 0
$cfgYml    = Join-Path $CfCredDir "config.yml"
$cfgExists = Test-Path $cfgYml
$credFiles = @(); if(Test-Path $CfCredDir){ $credFiles = Get-ChildItem $CfCredDir -Filter *.json -File -ErrorAction SilentlyContinue }
$credUse   = $null
if($credFiles){ $credUse = ($credFiles | Where-Object { $_.Name -like "$TunnelUuidPref*.json" } | Select-Object -First 1) }
if(-not $credUse -and $credFiles){ $credUse = $credFiles | Select-Object -First 1 }
$tunnelUuid = $null
if($credUse){ try{ $tunnelUuid = (Get-Content -Raw $credUse.FullName | ConvertFrom-Json).TunnelID }catch{} }
if(-not $tunnelUuid){ $tunnelUuid = $TunnelUuidPref }
$tunnel_ok = ($cfExists -and $cfRunning -and $credUse)

# --- DNS / PÚBLICO ---
$dnsCname=$null;$dnsA=$null;$dnsAAAA=$null
try{ $tmp = Resolve-DnsName $PublicHost -Type CNAME -Server 1.1.1.1 -ErrorAction Stop; if($tmp){ $dnsCname = $tmp.NameHost } }catch{}
try{ $dnsA     = Resolve-DnsName $PublicHost -Type A     -Server 1.1.1.1 -ErrorAction SilentlyContinue }catch{}
try{ $dnsAAAA  = Resolve-DnsName $PublicHost -Type AAAA  -Server 1.1.1.1 -ErrorAction SilentlyContinue }catch{}
$cnameExpected = $null; if($tunnelUuid){ $cnameExpected = "$tunnelUuid.cfargotunnel.com" }
$dnsOk = $false
if($dnsCname -and $cnameExpected){ $dnsOk = ($dnsCname -like "*$cnameExpected") -and (-not $dnsA) -and (-not $dnsAAAA) }
$pubDocs = HttpCheck ("https://{0}/docs" -f $PublicHost) 8
$public_ok = ($pubDocs.ok -and $pubDocs.status -eq 200)

# --- RELATÓRIO (objeto) ---
$credUsedPath = if($credUse){ $credUse.FullName } else { $null }
$report = [ordered]@{
  timestamp = $now
  backend   = [ordered]@{
    local_url      = $BackendLocal
    docs           = $bkDocs
    health         = $bkHealth
    port_listening = $bkListen
    summary        = (Pass $back_ok)
  }
  frontend  = @([ordered]@{ ports=$FrontPorts; checks=$frontChecks; summary=$frontendSummary })
  tunnel    = [ordered]@{
    cloudflared_path    = $cfPath
    cloudflared_running = $cfRunning
    credentials_dir     = $CfCredDir
    credential_used     = $credUsedPath
    tunnel_uuid         = $tunnelUuid
    config_yml          = @{ exists=$cfgExists; path=$cfgYml }
    summary             = (Pass $tunnel_ok)
  }
  public    = [ordered]@{
    hostname       = $PublicHost
    cname          = $dnsCname
    cname_expected = $cnameExpected
    has_A_or_AAAA  = [bool]($dnsA -or $dnsAAAA)
    https_docs     = $pubDocs
    dns_ok         = (Pass $dnsOk)
    summary        = (Pass $public_ok)
  }
}

# --- RELATÓRIO (texto) ---
$credUsedText = if($credUsedPath){ $credUsedPath } else { "(não definida)" }
$cnameText    = if($dnsCname){ $dnsCname } else { "(nenhum)" }
$cnameExpText = if($cnameExpected){ $cnameExpected } else { "(n/a)" }

$lines=@()
$lines += "=== LINK SEGURO :: HEALTCHECK $($report.timestamp) ==="
$lines += ""
$lines += "[Backend]"
$lines += ("  Local: {0}" -f $report.backend.local_url)
$lines += ("  /docs -> {0}"   -f (ShowStatus $report.backend.docs))
$lines += ("  /health -> {0}" -f (ShowStatus $report.backend.health))
$lines += ("  Porta ouvindo -> {0}" -f $report.backend.port_listening)
$lines += ("  => {0}" -f $report.backend.summary)
$lines += ""
$lines += "[Frontend]"
foreach($c in $frontChecks){ $lines += ("  Porta {0}: listening={1} http={2}" -f $c.port, $c.listening, (ShowStatus $c.http)) }
$lines += ("  => {0}" -f $frontendSummary)
$lines += ""
$lines += "[Tunnel]"
$lines += ("  cloudflared: {0} (running={1})" -f $report.tunnel.cloudflared_path, $report.tunnel.cloudflared_running)
$lines += ("  cred dir: {0}" -f $report.tunnel.credentials_dir)
$lines += ("  cred usada: {0}" -f $credUsedText)
$lines += ("  tunnel UUID: {0}" -f $report.tunnel.tunnel_uuid)
$lines += ("  config.yml: exists={0} path={1}" -f $report.tunnel.config_yml.exists, $report.tunnel.config_yml.path)
$lines += ("  => {0}" -f $report.tunnel.summary)
$lines += ""
$lines += "[Público]"
$lines += ("  hostname: {0}" -f $report.public.hostname)
$lines += ("  CNAME: {0}" -f $cnameText)
$lines += ("  esperado: {0}" -f $cnameExpText)
$lines += ("  A/AAAA?: {0}" -f $report.public.has_A_or_AAAA)
$lines += ("  https /docs -> {0}" -f (ShowStatus $report.public.https_docs))
$lines += ("  DNS OK? => {0}" -f $report.public.dns_ok)
$lines += ("  => {0}" -f $report.public.summary)
$lines += ""
$lines += "Relatório salvo em:"
$lines += "  $TXT"
$lines += "  $JSON"

$lines -join "`r`n" | Set-Content -Encoding UTF8 $TXT
$report | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 $JSON

Write-Host "`n--- RESUMO ---`n" -ForegroundColor Cyan
Get-Content $TXT | Select-Object -First 60


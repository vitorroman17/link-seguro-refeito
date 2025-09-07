$ErrorActionPreference="SilentlyContinue"
$root="C:\link-seguro-refeito"
$okB = (Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8000/docs -TimeoutSec 3).StatusCode -eq 200
$okF = (Test-NetConnection 127.0.0.1 -Port 5173).TcpTestSucceeded
$okP = (Invoke-WebRequest -UseBasicParsing https://app.vitorroman.com.br/docs -TimeoutSec 5).StatusCode -eq 200
"{0} backend | {1} frontend | {2} público" -f ($okB?"OK":"NOK"),($okF?"OK":"NOK"),($okP?"OK":"NOK")

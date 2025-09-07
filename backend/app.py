import os
import time
import uuid
import json
from datetime import datetime, timezone
from urllib.parse import urlparse, quote

import httpx
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

APP_NAME = "link-seguro"
APP_VERSION = "1.0.0"

ALLOWED_ORIGINS = [o.strip() for o in os.getenv("ALLOWED_ORIGINS", "http://127.0.0.1:5500,http://localhost:5500,https://app.vitorroman.com.br,https://api.vitorroman.com.br").split(",") if o.strip()]
OTX_API_KEY = os.getenv("OTX_API_KEY","").strip()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS or ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class LinkIn(BaseModel):
    url: str

@app.get("/healthz")
def healthz():
    return {"status":"ok", "app": APP_NAME, "version": APP_VERSION}

# ---------------- Heuristics ----------------
SUSPICIOUS_TOKENS = [
    "pix", "boleto", "secure", "verificar", "verify", "confirmar", "update",
    "login", "conta", "bank", "banco", "premio", "ganhador", "sorteio",
    "pagamento", "payment", "fatura", "senha", "password"
]

DANGEROUS_HOST_TOKENS = [
    "login", "secure", "payment", "pix", "boleto", "conta", "banco", "verificado"
]

def simple_heuristics(u: str):
    try:
        p = urlparse(u)
        host = (p.hostname or "").lower()
        pathq = (p.path + "?" + (p.query or "")).lower()
        score = 0
        for t in SUSPICIOUS_TOKENS:
            if t in pathq:
                score += 1
        for t in DANGEROUS_HOST_TOKENS:
            if t in host:
                score += 1
        if host.endswith(".example") or host.endswith(".example.com"):
            return "dangerous"
        if score >= 3:
            return "dangerous"
        if score == 2:
            return "suspicious"
        return "unknown"
    except Exception:
        return "unknown"

# ---------------- OTX ----------------
async def check_otx(u: str):
    if not OTX_API_KEY:
        return {"used": False, "decision": None, "error": "missing_api_key"}
    try:
        enc = quote(u, safe="")
        headers = {"X-OTX-API-KEY": OTX_API_KEY}
        async with httpx.AsyncClient(timeout=5.5) as client:
            r = await client.get(f"https://otx.alienvault.com/api/v1/indicators/url/{enc}/general", headers=headers)
            if r.status_code == 200:
                data = r.json()
                pulses = data.get("pulse_info",{}).get("count",0)
                if pulses and pulses > 0:
                    return {"used": True, "decision": "dangerous", "pulses":pulses, "what":"url"}
            host = (urlparse(u).hostname or "")
            if host:
                r2 = await client.get(f"https://otx.alienvault.com/api/v1/indicators/domain/{host}/general", headers=headers)
                if r2.status_code == 200:
                    d2 = r2.json()
                    pulses2 = d2.get("pulse_info",{}).get("count",0)
                    if pulses2 and pulses2 > 0:
                        return {"used": True, "decision": "dangerous", "pulses":pulses2, "what":"domain"}
        return {"used": True, "decision": "unknown"}
    except Exception as e:
        return {"used": True, "decision": "unknown", "error": str(e)[:200]}

# ---------------- Positive signals (free) ----------------
def is_punycode(host: str) -> bool:
    if not host:
        return False
    return host.startswith("xn--") or ".xn--" in host

async def rdap_age_days(host: str):
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            r = await client.get(f"https://rdap.org/domain/{host}")
            if r.status_code != 200:
                return None
            data = r.json()
            events = data.get("events", [])
            ts = None
            for ev in events:
                if ev.get("eventAction") in ("registration","registered","creation","create"):
                    ts = ev.get("eventDate")
                    break
            if not ts:
                return None
            dt = datetime.fromisoformat(ts.replace("Z","+00:00"))
            return (datetime.now(timezone.utc) - dt).days
    except Exception:
        return None

async def fetch_head(u: str):
    try:
        hdrs = {"User-Agent":"LinkSeguro/1.0 (+https://api.vitorroman.com.br)"}
        async with httpx.AsyncClient(timeout=6.0, follow_redirects=True, verify=True) as client:
            r = await client.get(u, headers=hdrs)
            chain = [str(h.url) for h in r.history] + [str(r.url)]
            headers = {k.lower(): v for k,v in r.headers.items()}
            return {"ok": True, "status": r.status_code, "final_url": str(r.url), "chain": chain, "headers": headers}
    except Exception as e:
        return {"ok": False, "error": str(e)[:200]}

async def positive_signals(u: str):
    p = urlparse(u)
    host = (p.hostname or "").lower()
    if p.scheme not in ("http","https") or not host:
        return {"score": 0, "reasons": ["bad_scheme_or_host"]}
    score = 0
    reasons = []
    if is_punycode(host):
        score -= 2
        reasons.append("punycode")

    head = await fetch_head(u)
    if head.get("ok"):
        status = head["status"]
        final = urlparse(head["final_url"])
        headers = head.get("headers",{})
        chain = head.get("chain",[])
        if 200 <= status < 400:
            score += 1; reasons.append("http_ok")
        if final.scheme == "https":
            score += 2; reasons.append("https")
        if headers.get("strict-transport-security"):
            score += 1; reasons.append("hsts")
        sec_headers = 0
        for hk in ("content-security-policy","x-frame-options","x-content-type-options","referrer-policy"):
            if headers.get(hk):
                sec_headers += 1
        if sec_headers:
            score += 1; reasons.append("sec_headers")
        if len(chain) > 4:
            score -= 1; reasons.append("too_many_redirects")
        if final.hostname and final.hostname != host:
            score -= 1; reasons.append("cross_host_redirect")
    else:
        reasons.append(f"net_error:{head.get('error','unknown')}")

    age = await rdap_age_days(host)
    if age is not None:
        if age >= 180:
            score += 2; reasons.append(f"age_{age}d")
        elif age >= 90:
            score += 1; reasons.append(f"age_{age}d")
        else:
            reasons.append(f"age_{age}d")

    return {"score": score, "reasons": reasons, "age_days": age}

# ---------------- Endpoint ----------------
@app.post("/validar_link")
async def validar_link(inp: LinkIn):
    t0 = time.time()
    trace = str(uuid.uuid4())
    url = inp.url.strip()

    extra = {}

    decision = simple_heuristics(url)
    source = "heuristics"

    otx_res = await check_otx(url)
    if otx_res.get("used"):
        extra["otx"] = {k:v for k,v in otx_res.items() if k != "used"}
        if otx_res.get("decision") == "dangerous":
            decision = "dangerous"
            source = "otx"

    ps = await positive_signals(url)
    extra["positive_signals"] = ps
    if decision != "dangerous":
        if ps.get("score",0) >= 3:
            decision = "safe"
            source = "positive_signals"

    took = int((time.time() - t0)*1000)
    return {
        "status":"success",
        "decision": decision,
        "trace_id": trace,
        "source": source,
        "url": url,
        "vt_summary": "",
        "error": "",
        "took_ms": took,
        "http_status": 200,
        "sent_trace": trace,
        "extra": extra
    }

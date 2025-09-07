
# Link Seguro — Refeito (para aula)

Foco: **logs claros** e **retornos úteis**. Mantém o fluxo original (frontend → `/api/validar_link` → FastAPI → VirusTotal).

## Rodando com Docker
```bash
cd link-seguro-refeito
# opcional: exportar sua chave do VirusTotal
# Linux/macOS: export VT_API_KEY="SUA_CHAVE"
# Windows (PowerShell): $env:VT_API_KEY="SUA_CHAVE"

docker compose up --build
# Front: http://localhost:99
# API:   http://localhost:8980 (ou via /api pelo front)
```
Sem `VT_API_KEY`, o backend retorna `decision="unknown"` (ou `"suspicious"` por heurística simples).

## Rodando local (sem Docker)
```bash
cd backend
python -m venv .venv && . .venv/bin/activate  # (Windows: .venv\Scripts\activate)
pip install -r requirements.txt
# opcional: setar VT_API_KEY no ambiente
uvicorn app:app --reload
# Front: abra link-seguro-refeito/frontend/index.html direto no navegador
```
Para usar o proxy `/api/` corretamente sem Docker, sirva o frontend (ex.: `python -m http.server` na pasta `frontend`) e acesse `http://localhost:8000` como backend.

## Logs
- Logs são **estruturados** em uma linha JSON por evento, com `trace_id` para correlação.
- O `trace_id` também é devolvido no JSON da resposta e no header `x-request-id`.
- Exemplo (stdout do backend):
```
{"ts":"2025-09-02T00:00:00","level":"INFO","msg":"request_received","trace_id":"...","extra":{"urlhash":"..."}}
{"ts":"2025-09-02T00:00:01","level":"INFO","msg":"vt_decision","trace_id":"...","extra":{"urlhash":"...","decision":"clean","stats":{"malicious":0,...}}}
```
- Em erro de rede/VT: `status="success", decision="unknown", source="virustotal_error", error="..."` (sem stacktrace exposto ao cliente).

## API
### `POST /validar_link`
Body:
```json
{ "url": "https://exemplo.com" }
```
Resposta (exemplo):
```json
{
  "status": "success",
  "decision": "clean",
  "trace_id": "b1d0...",
  "source": "virustotal",
  "url": "https://exemplo.com",
  "vt_summary": {
    "status": "completed",
    "stats": { "malicious": 0, "suspicious": 0, "harmless": 75, "undetected": 12 },
    "engines_malicious": [],
    "analysis_id": "u-...",
    "report_url": "https://www.virustotal.com/gui/url/u-..."
  },
  "error": null,
  "took_ms": 512
}
```

### `GET /healthz`
Retorna status do serviço e versão.

## Notas
- **Segurança**: CORS limitado por `ALLOWED_ORIGINS` (por padrão `http://localhost:99`). Não usar `*` em produção.
- **Privacidade**: URLs enviadas para VirusTotal podem ser compartilhadas/armazenadas. Para aula, está ok — documente isso se apresentar.
- **Heurística** (sem VT): marca `suspicious` se encontrar palavras como `"malware"`, `"phish"`, `"virus"`, `"trojan"` na URL; caso contrário, `unknown`.

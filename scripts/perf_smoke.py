"""Simple performance smoke script for pilot/staging baselining.

Run server first:
  python -m app.main
Then:
  python scripts/perf_smoke.py
"""
from __future__ import annotations

import json
import statistics
import time
import urllib.request

BASE = "http://127.0.0.1:8000"
TOKEN = "founder-admin-token"


def request(method: str, path: str, payload: dict | None = None) -> dict:
    data = json.dumps(payload).encode("utf-8") if payload is not None else None
    req = urllib.request.Request(
        BASE + path,
        method=method,
        data=data,
        headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main() -> None:
    request("POST", "/api/v1/dev/seed", {})
    latencies = []
    for _ in range(30):
        t0 = time.perf_counter()
        request("GET", "/api/v1/kpis")
        latencies.append((time.perf_counter() - t0) * 1000)

    p50 = statistics.median(latencies)
    p95 = sorted(latencies)[int(len(latencies) * 0.95) - 1]
    print(json.dumps({"samples": len(latencies), "p50_ms": round(p50, 2), "p95_ms": round(p95, 2), "max_ms": round(max(latencies), 2)}, indent=2))


if __name__ == "__main__":
    main()

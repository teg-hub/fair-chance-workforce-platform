import sys
from pathlib import Path as _P

sys.path.insert(0, str(_P(__file__).resolve().parents[1]))

import json
import threading
import time
import urllib.request
import urllib.error
from http.server import ThreadingHTTPServer

from app.main import AppHandler, init_db

PORT = 8011
BASE = f"http://127.0.0.1:{PORT}"
HEADERS = {"Authorization": "Bearer founder-admin-token", "Content-Type": "application/json"}


def _request(method: str, path: str, payload: dict | None = None) -> dict:
    data = json.dumps(payload).encode("utf-8") if payload is not None else None
    req = urllib.request.Request(BASE + path, method=method, data=data, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=5) as resp:
        return json.loads(resp.read().decode("utf-8"))


def test_end_to_end_vertical_slice():
    init_db()
    server = ThreadingHTTPServer(("127.0.0.1", PORT), AppHandler)
    t = threading.Thread(target=server.serve_forever, daemon=True)
    t.start()
    time.sleep(0.05)

    try:
        health_req = urllib.request.Request(BASE + "/health", method="GET")
        with urllib.request.urlopen(health_req, timeout=5) as resp:
            health = json.loads(resp.read().decode("utf-8"))
        assert health["status"] == "ok"

        _request("POST", "/api/v1/dev/seed", {})
        referral = _request(
            "POST",
            "/api/v1/referrals",
            {
                "intake_path": "referral",
                "source_type": "manager",
                "employee_id": "e-1",
                "risk_level": "medium",
                "support_category_codes": ["housing", "transportation"],
                "assigned_coordinator_id": "u-coord",
            },
        )
        case = _request(
            "POST",
            "/api/v1/cases",
            {
                "employee_id": "e-1",
                "assigned_coordinator_id": "u-coord",
                "referral_id": referral["id"],
            },
        )
        _request(
            "POST",
            "/api/v1/progress-notes",
            {
                "employee_id": "e-1",
                "case_id": case["id"],
                "note_type": "coaching_session",
                "note_start_date": "2026-02-01",
                "interaction_at": "2026-02-01T15:00:00Z",
                "meeting_location": "office",
                "areas_of_need_codes": ["housing"],
                "summary_of_meeting": "Follow-up completed",
                "status": "final",
            },
        )
        kpis = _request("GET", "/api/v1/kpis")
        assert kpis["intake_volume"] >= 1
        assert kpis["case_open_count"] >= 1
        assert kpis["employee_engagement_count"] >= 1
    finally:
        server.shutdown()
        server.server_close()


def test_validation_errors_return_400():
    init_db()
    server = ThreadingHTTPServer(("127.0.0.1", PORT + 1), AppHandler)
    t = threading.Thread(target=server.serve_forever, daemon=True)
    t.start()
    time.sleep(0.05)

    base = f"http://127.0.0.1:{PORT + 1}"
    headers = {"Authorization": "Bearer founder-admin-token", "Content-Type": "application/json"}

    def req(method: str, path: str, payload: dict | None = None):
        data = json.dumps(payload).encode("utf-8") if payload is not None else None
        request = urllib.request.Request(base + path, method=method, data=data, headers=headers)
        try:
            with urllib.request.urlopen(request, timeout=5) as resp:
                return resp.status, json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            return e.code, json.loads(e.read().decode("utf-8"))

    try:
        req("POST", "/api/v1/dev/seed", {})
        status, _ = req("POST", "/api/v1/referrals", {
            "intake_path": "referral",
            "source_type": "manager",
            "employee_id": "e-1",
            "risk_level": "medium",
            "support_category_codes": []
        })
        assert status == 400

        status, _ = req("POST", "/api/v1/cases", {
            "employee_id": "e-1",
            "assigned_coordinator_id": "u-coord",
            "referral_id": "missing-ref"
        })
        assert status == 404

        # create valid case first
        status, body = req("POST", "/api/v1/cases", {
            "employee_id": "e-1",
            "assigned_coordinator_id": "u-coord"
        })
        assert status == 200

        status, _ = req("POST", "/api/v1/progress-notes", {
            "employee_id": "e-1",
            "case_id": body["id"],
            "note_type": "coaching_session",
            "note_start_date": "02-01-2026",
            "interaction_at": "not-a-date",
            "meeting_location": "office",
            "areas_of_need_codes": ["housing"]
        })
        assert status == 400
    finally:
        server.shutdown()
        server.server_close()

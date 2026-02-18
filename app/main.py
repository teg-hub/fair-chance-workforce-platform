from __future__ import annotations

import json
import sqlite3
from datetime import datetime, date
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any
from urllib.parse import urlparse
from uuid import uuid4

DB_PATH = Path(__file__).resolve().parent.parent / "fair_chance.db"

TOKENS = {
    "founder-admin-token": {"user_id": "u-admin", "tenant_id": "tenant-acme", "role": "company_admin"},
    "coordinator-token": {"user_id": "u-coord", "tenant_id": "tenant-acme", "role": "coordinator"},
    "manager-token": {"user_id": "u-manager", "tenant_id": "tenant-acme", "role": "manager"},
}

MEETING_LOCATIONS = {"office", "garage", "newberry", "community", "phone", "video", "text", "email"}
NOTE_TYPES = {"intake", "coaching_session", "resource_referral", "crisis", "follow_up"}
RISK_LEVELS = {"low", "medium", "high", "critical"}
SOURCE_TYPES = {"employee_self", "manager", "coordinator", "hr", "anonymous_other"}
INTAKE_PATHS = {"referral", "direct_engagement"}


def utcnow() -> str:
    return datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def get_db() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db() -> None:
    conn = get_db()
    cur = conn.cursor()
    cur.executescript(
        """
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            tenant_id TEXT NOT NULL,
            email TEXT NOT NULL,
            role TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS employees (
            id TEXT PRIMARY KEY,
            tenant_id TEXT NOT NULL,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            email TEXT
        );
        CREATE TABLE IF NOT EXISTS referrals (
            id TEXT PRIMARY KEY,
            tenant_id TEXT NOT NULL,
            intake_path TEXT NOT NULL,
            source_type TEXT NOT NULL,
            employee_id TEXT NOT NULL,
            referral_status TEXT NOT NULL,
            risk_level TEXT NOT NULL,
            support_category_codes TEXT NOT NULL,
            submitted_by_user_id TEXT NOT NULL,
            assigned_coordinator_id TEXT,
            submitted_at TEXT NOT NULL,
            first_response_at TEXT
        );
        CREATE TABLE IF NOT EXISTS cases (
            id TEXT PRIMARY KEY,
            tenant_id TEXT NOT NULL,
            employee_id TEXT NOT NULL,
            referral_id TEXT,
            assigned_coordinator_id TEXT NOT NULL,
            case_status TEXT NOT NULL,
            opened_at TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS progress_notes (
            id TEXT PRIMARY KEY,
            tenant_id TEXT NOT NULL,
            employee_id TEXT NOT NULL,
            case_id TEXT NOT NULL,
            coordinator_id TEXT NOT NULL,
            note_type TEXT NOT NULL,
            note_start_date TEXT NOT NULL,
            interaction_at TEXT NOT NULL,
            meeting_location TEXT NOT NULL,
            areas_of_need_codes TEXT NOT NULL,
            summary_of_meeting TEXT,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL
        );
        """
    )
    conn.commit()
    conn.close()




def _is_iso_date(value: str) -> bool:
    try:
        date.fromisoformat(value)
        return True
    except ValueError:
        return False


def _is_iso_datetime(value: str) -> bool:
    normalized = value.replace("Z", "+00:00")
    try:
        datetime.fromisoformat(normalized)
        return True
    except ValueError:
        return False

def parse_auth(header: str | None) -> dict[str, str] | None:
    if not header or not header.startswith("Bearer "):
        return None
    token = header.replace("Bearer ", "", 1).strip()
    return TOKENS.get(token)


class AppHandler(BaseHTTPRequestHandler):
    server_version = "FairChanceHTTP/0.1"

    def _send(self, status: int, body: dict[str, Any]) -> None:
        payload = json.dumps(body).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _read_json(self) -> dict[str, Any] | None:
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length) if length else b"{}"
        try:
            return json.loads(raw.decode("utf-8")) if raw else {}
        except json.JSONDecodeError:
            self._send(400, {"detail": "Invalid JSON body"})
            return None

    def _auth(self) -> dict[str, str] | None:
        return parse_auth(self.headers.get("Authorization"))

    def do_GET(self) -> None:  # noqa: N802
        path = urlparse(self.path).path
        if path == "/health":
            self._send(200, {"status": "ok"})
            return

        auth = self._auth()
        if auth is None:
            self._send(401, {"detail": "Missing or invalid bearer token"})
            return

        if path == "/api/v1/me":
            self._send(200, auth)
            return

        if path == "/api/v1/kpis":
            conn = get_db()
            cur = conn.cursor()
            tenant = auth["tenant_id"]
            cur.execute("SELECT COUNT(*) c FROM referrals WHERE tenant_id=?", (tenant,))
            intake_volume = cur.fetchone()["c"]
            cur.execute("SELECT COUNT(*) c FROM cases WHERE tenant_id=? AND case_status IN ('open','active_support')", (tenant,))
            case_open_count = cur.fetchone()["c"]
            cur.execute("SELECT COUNT(*) c FROM progress_notes WHERE tenant_id=?", (tenant,))
            engagement = cur.fetchone()["c"]
            cur.execute("SELECT COUNT(*) c FROM referrals WHERE tenant_id=? AND assigned_coordinator_id IS NOT NULL", (tenant,))
            assigned = cur.fetchone()["c"]
            cur.execute("SELECT COUNT(*) c FROM referrals WHERE tenant_id=? AND assigned_coordinator_id IS NOT NULL AND first_response_at IS NOT NULL", (tenant,))
            responded = cur.fetchone()["c"]
            cur.execute("SELECT COUNT(*) c FROM progress_notes WHERE tenant_id=?", (tenant,))
            notes_total = cur.fetchone()["c"]
            cur.execute("SELECT COUNT(*) c FROM progress_notes WHERE tenant_id=? AND status='final'", (tenant,))
            notes_final = cur.fetchone()["c"]
            conn.close()
            self._send(
                200,
                {
                    "intake_volume": intake_volume,
                    "case_open_count": case_open_count,
                    "employee_engagement_count": engagement,
                    "referral_response_rate": round((responded / assigned), 4) if assigned else 0.0,
                    "progress_note_submission_rate": round((notes_final / notes_total), 4) if notes_total else 0.0,
                },
            )
            return

        self._send(404, {"detail": "Not found"})

    def do_POST(self) -> None:  # noqa: N802
        path = urlparse(self.path).path
        auth = self._auth()
        if auth is None:
            self._send(401, {"detail": "Missing or invalid bearer token"})
            return
        body = self._read_json()
        if body is None:
            return

        if path == "/api/v1/dev/seed":
            conn = get_db()
            cur = conn.cursor()
            for u in [
                ("u-admin", auth["tenant_id"], "admin@example.com", "company_admin"),
                ("u-coord", auth["tenant_id"], "coord@example.com", "coordinator"),
                ("u-manager", auth["tenant_id"], "manager@example.com", "manager"),
            ]:
                cur.execute("INSERT OR IGNORE INTO users(id,tenant_id,email,role) VALUES(?,?,?,?)", u)
            for e in [
                ("e-1", auth["tenant_id"], "Ava", "Reed", "ava@example.com"),
                ("e-2", auth["tenant_id"], "Noah", "Cole", "noah@example.com"),
            ]:
                cur.execute("INSERT OR IGNORE INTO employees(id,tenant_id,first_name,last_name,email) VALUES(?,?,?,?,?)", e)
            conn.commit()
            conn.close()
            self._send(200, {"users": 3, "employees": 2})
            return

        if path == "/api/v1/referrals":
            required = {"intake_path", "source_type", "employee_id", "risk_level", "support_category_codes"}
            if not required.issubset(body.keys()):
                self._send(400, {"detail": "Missing required fields"})
                return
            if body["intake_path"] not in INTAKE_PATHS or body["source_type"] not in SOURCE_TYPES or body["risk_level"] not in RISK_LEVELS:
                self._send(400, {"detail": "Invalid intake/source/risk enum"})
                return
            if not isinstance(body.get("support_category_codes"), list) or len(body.get("support_category_codes", [])) == 0:
                self._send(400, {"detail": "support_category_codes must be a non-empty array"})
                return

            conn = get_db()
            cur = conn.cursor()
            cur.execute("SELECT tenant_id FROM employees WHERE id=?", (body["employee_id"],))
            emp = cur.fetchone()
            if not emp:
                conn.close()
                self._send(404, {"detail": "Employee not found"})
                return
            if emp["tenant_id"] != auth["tenant_id"]:
                conn.close()
                self._send(403, {"detail": "Cross-tenant access denied"})
                return

            referral_id = str(uuid4())
            cur.execute(
                """
                INSERT INTO referrals(id,tenant_id,intake_path,source_type,employee_id,referral_status,risk_level,
                                      support_category_codes,submitted_by_user_id,assigned_coordinator_id,submitted_at)
                VALUES(?,?,?,?,?,?,?,?,?,?,?)
                """,
                (
                    referral_id,
                    auth["tenant_id"],
                    body["intake_path"],
                    body["source_type"],
                    body["employee_id"],
                    "submitted",
                    body["risk_level"],
                    ",".join(body.get("support_category_codes", [])),
                    auth["user_id"],
                    body.get("assigned_coordinator_id"),
                    utcnow(),
                ),
            )
            conn.commit()
            conn.close()
            self._send(200, {"id": referral_id, "referral_status": "submitted"})
            return

        if path == "/api/v1/cases":
            required = {"employee_id", "assigned_coordinator_id"}
            if not required.issubset(body.keys()):
                self._send(400, {"detail": "Missing required fields"})
                return
            conn = get_db()
            cur = conn.cursor()
            cur.execute("SELECT tenant_id FROM employees WHERE id=?", (body["employee_id"],))
            emp = cur.fetchone()
            if not emp:
                conn.close()
                self._send(404, {"detail": "Employee not found"})
                return
            if emp["tenant_id"] != auth["tenant_id"]:
                conn.close()
                self._send(403, {"detail": "Cross-tenant access denied"})
                return

            referral_id = body.get("referral_id")
            if referral_id:
                cur.execute("SELECT tenant_id, first_response_at FROM referrals WHERE id=?", (referral_id,))
                ref = cur.fetchone()
                if not ref:
                    conn.close()
                    self._send(404, {"detail": "Referral not found"})
                    return
                if ref["tenant_id"] != auth["tenant_id"]:
                    conn.close()
                    self._send(403, {"detail": "Cross-tenant access denied"})
                    return
                cur.execute("SELECT employee_id FROM referrals WHERE id=?", (referral_id,))
                ref_employee = cur.fetchone()
                if ref_employee and ref_employee["employee_id"] != body["employee_id"]:
                    conn.close()
                    self._send(400, {"detail": "Referral/employee mismatch"})
                    return
                cur.execute(
                    "UPDATE referrals SET referral_status='converted_to_case', first_response_at=COALESCE(first_response_at, ?) WHERE id=?",
                    (utcnow(), referral_id),
                )

            case_id = str(uuid4())
            cur.execute(
                "INSERT INTO cases(id,tenant_id,employee_id,referral_id,assigned_coordinator_id,case_status,opened_at) VALUES(?,?,?,?,?,?,?)",
                (case_id, auth["tenant_id"], body["employee_id"], referral_id, body["assigned_coordinator_id"], "open", utcnow()),
            )
            conn.commit()
            conn.close()
            self._send(200, {"id": case_id, "case_status": "open"})
            return

        if path == "/api/v1/progress-notes":
            required = {
                "employee_id",
                "case_id",
                "note_type",
                "note_start_date",
                "interaction_at",
                "meeting_location",
                "areas_of_need_codes",
            }
            if not required.issubset(body.keys()):
                self._send(400, {"detail": "Missing required fields"})
                return
            if body["note_type"] not in NOTE_TYPES:
                self._send(400, {"detail": "Invalid note_type"})
                return
            if not _is_iso_date(body["note_start_date"]):
                self._send(400, {"detail": "note_start_date must be ISO date (YYYY-MM-DD)"})
                return
            if not _is_iso_datetime(body["interaction_at"]):
                self._send(400, {"detail": "interaction_at must be ISO datetime"})
                return
            if body["meeting_location"] not in MEETING_LOCATIONS:
                self._send(400, {"detail": "Invalid meeting_location"})
                return
            if body.get("status", "draft") not in {"draft", "final"}:
                self._send(400, {"detail": "Invalid status"})
                return

            conn = get_db()
            cur = conn.cursor()
            cur.execute("SELECT tenant_id, employee_id FROM cases WHERE id=?", (body["case_id"],))
            case_row = cur.fetchone()
            if not case_row:
                conn.close()
                self._send(404, {"detail": "Case not found"})
                return
            if case_row["tenant_id"] != auth["tenant_id"]:
                conn.close()
                self._send(403, {"detail": "Cross-tenant access denied"})
                return
            if case_row["employee_id"] != body["employee_id"]:
                conn.close()
                self._send(400, {"detail": "Employee/case mismatch"})
                return

            note_id = str(uuid4())
            cur.execute(
                """
                INSERT INTO progress_notes(id,tenant_id,employee_id,case_id,coordinator_id,note_type,note_start_date,
                                           interaction_at,meeting_location,areas_of_need_codes,summary_of_meeting,status,created_at)
                VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)
                """,
                (
                    note_id,
                    auth["tenant_id"],
                    body["employee_id"],
                    body["case_id"],
                    auth["user_id"],
                    body["note_type"],
                    body["note_start_date"],
                    body["interaction_at"],
                    body["meeting_location"],
                    ",".join(body.get("areas_of_need_codes", [])),
                    body.get("summary_of_meeting"),
                    body.get("status", "draft"),
                    utcnow(),
                ),
            )
            conn.commit()
            conn.close()
            self._send(200, {"id": note_id, "status": body.get("status", "draft")})
            return

        self._send(404, {"detail": "Not found"})


def run(host: str = "127.0.0.1", port: int = 8000) -> None:
    init_db()
    server = ThreadingHTTPServer((host, port), AppHandler)
    print(f"Serving Fair Chance API on http://{host}:{port}")
    server.serve_forever()


if __name__ == "__main__":
    run()

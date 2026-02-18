# Fair Chance Workforce Enablement Platform

An AI-enabled product blueprint plus a runnable pilot vertical slice for fair chance employment programs.

## Product Vision
This platform helps employers and social service teams support employees with barriers to employment by combining:

1. **Employee Intake & Self-Referral**
2. **Individualized Development Plans**
3. **Case Management & Documentation**
4. **Program Analytics & KPI Dashboards**
5. **Company-Specific Customization**

The system is designed for multi-tenant deployment so each company can tailor workflows, outcomes, and reporting.

## What’s Included in This Repository
- `app/main.py` – runnable Python/SQLite HTTP vertical slice (auth + intake + case + notes + KPI read model)
- `tests/test_vertical_slice.py` – end-to-end API test for the vertical slice
- `scripts/perf_smoke.py` – performance smoke script for staging/pilot baselining
- `docs/fair-chance-platform-blueprint.md` – full product blueprint and workflow design
- `docs/domain-model.sql` – starter relational data model for a production MVP
- `docs/sample-kpi-config.json` – example tenant-specific KPI configuration
- `docs/ai-workflows.md` – AI workflow patterns, guardrails, and prompt templates
- `docs/option-a-parameter-ingestion.md` – translated requirements from uploaded scope document (Glide-style -> Vercel-ready)
- `docs/canonical-requirements-pack.md` – normalized nomenclature, enums, and workflow anchors
- `docs/openapi-endpoints.md` – MVP API endpoint contract draft aligned to the schema
- `docs/mvp-execution-plan.md` – sprint-by-sprint MVP delivery plan
- `docs/progress-note-form-spec.md` – required progress-note fields and dropdown enums from latest UI screenshots
- `docs/kpi-parameter-ingestion.md` – founder KPI slide translated into implementation-ready metric definitions
- `docs/platform-build-synopsis.md` + `docs/platform-build-synopsis.pdf` – downloadable high-level synopsis

## Runnable Vertical Slice (Now)
Implemented endpoints:
- `GET /api/v1/me` (token-based auth context)
- `POST /api/v1/referrals` (intake path: `referral` or `direct_engagement`)
- `POST /api/v1/cases` (case creation and referral conversion)
- `POST /api/v1/progress-notes` (required note date/location fields)
- `GET /api/v1/kpis` (KPI read model for intake/cases/engagement/response/submission rates)
- `POST /api/v1/dev/seed` (local/staging seed helper)
- `GET /health`

### Local Run
```bash
python3 -m app.main
```

### Demo Tokens
Use as Bearer tokens in `Authorization` header:
- `founder-admin-token`
- `coordinator-token`
- `manager-token`

### Quick Smoke
```bash
pytest -q
```

## Performance Baseline for Staging/Pilot
After launching the API:
```bash
python3 scripts/perf_smoke.py
```
The script returns request latency stats (`p50`, `p95`, `max`) for `GET /api/v1/kpis` to establish an initial benchmark and compare future optimizations.

## Suggested MVP Build Stack (Vercel-Oriented)
- **Frontend:** Next.js + TypeScript + Tailwind (employee portal + coordinator console + admin analytics)
- **Backend (current pilot):** Python HTTP service (`app/main.py`)
- **Backend (target production options):** Next.js Route Handlers / Server Actions or a dedicated Python/FastAPI service
- **Database:** PostgreSQL (e.g., Neon/Supabase/Postgres-compatible)
- **Auth & Access:** SSO/OIDC + role-based access control
- **AI Layer:** LLM service with retrieval, workflow prompts, and human review checkpoints
- **Infrastructure:** Vercel + managed services with audit logs and encryption

## Core User Roles
- Employee (self-referral and progress tracking)
- Coordinator
- Program Manager
- Company Admin
- Platform Super Admin (optional)

## Success Outcomes
- Increase employee participation in supportive services
- Improve completion rates for development plans
- Improve retention and advancement metrics
- Provide transparent, auditable program outcomes

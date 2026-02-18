# Fair Chance Workforce Enablement Platform

An AI-enabled product blueprint for organizations running fair chance employment programs.

## Product Vision
This platform helps employers and social service teams support employees with barriers to employment by combining:

1. **Employee Intake & Self-Referral**
2. **Individualized Development Plans**
3. **Case Management & Documentation**
4. **Program Analytics & KPI Dashboards**
5. **Company-Specific Customization**

The system is designed for multi-tenant deployment so each company can tailor workflows, outcomes, and reporting.

## What’s Included in This Repository
- `docs/fair-chance-platform-blueprint.md` – full product blueprint and workflow design
- `docs/domain-model.sql` – starter relational data model for a production MVP
- `docs/sample-kpi-config.json` – example tenant-specific KPI configuration
- `docs/ai-workflows.md` – AI workflow patterns, guardrails, and prompt templates
- `docs/option-a-parameter-ingestion.md` – translated requirements from your uploaded scope document (Glide-style -> Vercel-ready)
- `docs/canonical-requirements-pack.md` – normalized nomenclature, enums, and workflow anchors
- `docs/openapi-endpoints.md` – MVP API endpoint contract draft aligned to the schema
- `docs/mvp-execution-plan.md` – sprint-by-sprint MVP delivery plan
- `docs/progress-note-form-spec.md` – required progress-note fields and dropdown enums from latest UI screenshots
- `docs/kpi-parameter-ingestion.md` – founder KPI slide translated into implementation-ready metric definitions

## Suggested MVP Build Stack (Vercel-Oriented)
- **Frontend:** Next.js + TypeScript + Tailwind (employee portal + coordinator console + admin analytics)
- **Backend:** Next.js Route Handlers / Server Actions or separate Python/FastAPI service for heavy workflows
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

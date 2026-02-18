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

## Suggested MVP Build Stack
- **Frontend:** React + TypeScript (employee portal + case worker console + admin analytics)
- **Backend:** Node.js/TypeScript or Python/FastAPI
- **Database:** PostgreSQL
- **Auth & Access:** SSO/OIDC + role-based access control
- **AI Layer:** LLM service with retrieval, workflow prompts, and human review checkpoints
- **Infrastructure:** Multi-tenant cloud deployment with audit logs and encryption

## Core User Roles
- Employee (self-referral and progress tracking)
- Social Service Worker / Case Manager
- Program Manager
- Company Admin
- Platform Super Admin (optional)

## Success Outcomes
- Increase employee participation in supportive services
- Improve completion rates for development plans
- Improve retention and advancement metrics
- Provide transparent, auditable program outcomes

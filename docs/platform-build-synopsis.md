# Fair Chance Workforce Enablement Platform — Build Synopsis (Current State)

## 1) High-Level Build Summary

The repository currently provides an **implementation-ready product blueprint** for a multi-tenant Fair Chance Workforce Enablement Platform with AI-assisted workflows.

It includes:
- A complete product blueprint and module definitions.
- A case-centric PostgreSQL starter schema.
- A draft MVP API endpoint contract.
- AI workflow patterns with human-review guardrails.
- KPI definitions and tenant-level KPI configuration.
- A sprint-by-sprint MVP execution plan.

At this stage, the build is a **strong architecture/specification package** ready for engineering implementation, rather than a deployed production application.

## 2) Tenant-Side Experience

A tenant (company) experience is designed as follows:

1. **Configure program settings**
   - Timezone, quiet hours, templates, workflow rules, survey instruments, and KPI definitions are tenant-scoped.

2. **Role-based operations**
   - Employee, Coordinator, Manager, Program Manager, and Company Admin roles are supported.
   - Caseload-based access controls are part of the design.

3. **Run intake and engagement workflows**
   - Supports both **Referral** and **Direct Engagement** intake paths.
   - Triage, assignment, and case conversion workflows are defined.

4. **Manage cases and development plans**
   - Case lifecycle, development plan versioning, structured progress notes, and document metadata are modeled.

5. **Track communications and consent**
   - Consent records, campaigns (email/SMS/in-app), quiet-hours, and delivery tracking are included.

6. **Measure impact and operations**
   - Program-level and coordinator-level KPI scorecards, cohort slicing, and threshold alerts are specified.

## 3) Current Functional Coverage

### What it is able to do today (in-repo)
- Provide a complete and coherent specification baseline for product, design, and engineering teams.
- Define database entities and relationships for core modules.
- Define API surfaces and workflow/state expectations.
- Define KPI formulas, cohorts, and alerts.
- Define responsible AI boundaries and approval checkpoints.

### What is not yet implemented as runtime software
- No live web app or API server is shipped in this repo yet.
- No production telemetry exists yet for real performance benchmarks.
- No tenant-facing hosted environment has been configured from this repository alone.

## 4) Performance Status

Current performance posture is **design-defined** rather than empirically measured:
- KPI refresh cadence and alerting behavior are specified in configuration.
- Access control, auditability, and workflow controls are defined.
- Operational and user performance metrics will be measurable once a runnable implementation is deployed and instrumented.

## 5) Suggested Immediate Next Build Step

Build the first vertical slice in code:
1. Auth + tenant scoping
2. Referral/direct-engagement intake
3. Case creation + progress note save/finalize
4. One coordinator KPI endpoint

That sequence will allow early pilot validation and measurable performance baselines.

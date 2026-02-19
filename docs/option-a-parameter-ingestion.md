# Option A Ingestion: Uploaded Scope Parameters (Image-to-Spec Translation)

This document translates the uploaded scope notes (originally authored for Glide) into implementation-ready requirements for a Vercel deployment model.

## 1) What was captured from your uploaded scope notes

## Referral
- Intake should support three entry paths:
  1. Coordinator entry
  2. Manager entry
  3. Employee self-entry
- Ability to connect to external booking systems (example: Microsoft Bookings calendar/table).
- Support multi-select need categories (food, clothing, housing, legal, mental health/wellness, transportation).
- Coordinators should only see referrals in their caseload.
- Referral records should support de-duplication / manual merge when name typos produce duplicate employee records.
- Archive old referrals (move to archive table/state).

## Employee identity and profile
- Store first name and last name separately.
- Support editable and archivable employee profiles.

## Development planning
- Coordinators create custom development plans per employee.
- Goals are aligned to referral categories.
- Plans can be updated over time.

## Progress notes
- Coordinators document engagements and summarize outcomes.
- Notes should cover development-plan goals, direct service efforts, and external partner connections.
- Coordinators should only see notes tied to their caseload.
- Add more structured fields (traditional case note style).
- **Add explicit start date field** in progress notes.

## Partnerships, feedback, assessment, and resources
- Track external partnerships and fidelity to MOU/agreement terms over time.
- Employees provide periodic service feedback; trends tracked over time.
- Coordinators run periodic needs assessments to identify long-term prevention opportunities.
- Track resource presentations and attendance frequency.

## KPI and operational requirements
- Program-level and coordinator-level KPI dashboards.
- Include stability improvements, conversion to resource access, service utilization, partner fidelity, awareness, response rates, engagement counts, time allocation, feedback/satisfaction, and documentation completion rates.
- Generate AI/email/text blasts.
- Upload documents.
- Print progress notes and development plans.
- Generate reports.
- Caseload filtered by user; include past notes and current/past development plans.

---

## 2) Glide -> Vercel translation notes

- Glide “calendar table integration” maps to a provider abstraction in backend (Microsoft Bookings first; extendable to Calendly/Google later).
- Glide-style visibility filters map to RBAC + row-level authorization checks in API queries.
- “Archive to another table” maps to either:
  - soft-delete + status model, or
  - explicit archive tables for immutable historical snapshots.
- Print/export requirements map to server-generated PDF endpoints and downloadable report jobs.

---

## 3) Clarifications identified from the uploaded notes

- “No referral in workflow anymore” appears in KPI notes; recommend supporting both referral and non-referral engagements so KPIs remain valid across program variants.
- Duplicate “Legal” category appeared in the source notes; normalized to one legal category.
- Some KPIs imply periodic survey collection; platform should include survey instruments and cadence settings.

---

## 4) Recommendations added based on your scope

1. Add a **Survey & Instrument Builder** module (for stability index, awareness, satisfaction).
2. Add a **Partner Performance** scorecard linked to MOU obligations.
3. Add a **Communication Orchestrator** for batch email/SMS with consent gating.
4. Add **Record Merge Audit** logs to preserve lineage when duplicates are merged.
5. Add **Dual Path Enrollment** (referral path + direct engagement path) to support current and future workflows.

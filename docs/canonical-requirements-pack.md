# Canonical Requirements Pack (Consolidated from Founder-Provided Spec)

This document normalizes nomenclature and implementation requirements so product, design, and engineering work from one shared source.

## 1) Canonical Nomenclature

| Term | Definition | Deprecated Synonyms |
|---|---|---|
| Tenant | Employer organization partition in multi-tenant app | client org |
| Employee | Person receiving services | participant, client |
| Coordinator | Case management role owning caseload | case worker, navigator |
| Referral | Structured intake request | intake request |
| Direct Engagement | Intake path without referral | walk-in |
| Case | Container for ongoing support work | file |
| Development Plan | Versioned goals/actions for case | success plan |
| Progress Note | Structured interaction record with required start date | case note |
| Partner Fidelity Assessment | Periodic partner performance review | partner eval |

## 2) Required Modules and Core Rules

- Support both `referral` and `direct_engagement` intake paths.
- Enforce caseload-scoped visibility for coordinators.
- Keep first and last name as separate fields.
- Support duplicate employee merge with lineage/audit.
- Require `start_date` on progress notes.
- Track partner fidelity, employee feedback, needs assessments, resource presentations.
- Support program-level and coordinator-level KPI scorecards.
- Enforce consent checks for SMS/email communications.

## 3) Minimum Enumerations

- `intake_path`: `referral`, `direct_engagement`
- `referral_source`: `employee_self`, `manager`, `coordinator`, `hr`, `anonymous_other`
- `support_category`: `food`, `clothing`, `housing`, `legal`, `mental_health_wellness`, `transportation`
- `risk_level`: `low`, `medium`, `high`, `critical`
- `progress_note_status`: `draft`, `final`, `amended`
- `campaign_status`: `draft`, `scheduled`, `sending`, `paused`, `sent`, `cancelled`

## 4) Workflow Anchors

### Referral
`submitted -> triaged -> assigned -> contacted -> in_progress -> converted_to_case -> closed`

### Direct Engagement
`initiated -> case_opened -> active_support -> closed`

### Progress Note
`draft -> final -> amended` (amendment creates new version)

## 5) Data/Compliance Anchors

- Use UTC timestamps (`timestamptz`), display in tenant timezone.
- Classify sensitive free text as protected/limited-access fields.
- Audit key events (merge, export, send campaign, status transitions).
- No autonomous adverse AI decisions.


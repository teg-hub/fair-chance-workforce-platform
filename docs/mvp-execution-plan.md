# MVP Execution Plan (Next Steps)

## Sprint 1: Foundation + Access Controls
- Implement tenant-aware auth context and role claims.
- Implement row-level authorization policy service (coordinator caseload scope).
- Create `audit_events` writer middleware for all mutating endpoints.
- Deliver employee search/create/merge APIs with lineage logging.

## Sprint 2: Intake + Case Bootstrapping
- Build referral intake API and UI for three source types.
- Add direct engagement intake path and case auto-creation.
- Add triage and assignment actions with SLA timers.
- Add basic coordinator caseload list and filtering.

## Sprint 3: Development Plans + Progress Notes
- Implement development plan CRUD + versioning.
- Implement progress notes draft/final/amend flows.
- Enforce required `note_start_date` and structured fields.
- Add document upload metadata linkage to case/note/plan.

## Sprint 4: Communications + Consent
- Implement consent model and guard checks.
- Add campaign draft/schedule/send workflow.
- Wire email/SMS provider callbacks into delivery status tracking.
- Add quiet-hours and suppression logic.

## Sprint 5: Surveys, Assessments, Partners
- Implement feedback survey submission endpoints.
- Implement needs assessment capture and history.
- Implement partner registry + fidelity assessments.
- Implement resource presentation + attendance tracking.

## Sprint 6: Analytics + Reporting
- Ship KPI query endpoints for program/coordinator scorecards.
- Implement cohort filters and saved views.
- Implement export jobs for reports and print packets.
- Add KPI alert rules for key thresholds.

## Definition of Done (MVP)
- Dual intake paths are production-ready (`referral`, `direct_engagement`).
- Coordinator caseload access restrictions enforced end-to-end.
- Development plans and progress notes support auditable versioning.
- Communications require explicit channel consent and honor quiet hours.
- KPI dashboard supports program and coordinator views with exports.

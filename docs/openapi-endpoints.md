# API Contract Draft (MVP)

This endpoint catalog aligns with the canonical requirements and case-centric schema.

## Conventions
- Base path: `/api/v1`
- Auth: Bearer token (OIDC/SSO)
- Multi-tenant scoping: tenant derived from auth context, not URL path
- All writes emit `audit_events`

## Identity & Employee
- `POST /auth/login` – authenticate user session
- `GET /me` – current user context and permissions
- `POST /employees/search` – find candidate employee matches for dedupe
- `POST /employees` – create employee
- `GET /employees/{employeeId}` – read employee profile
- `PATCH /employees/{employeeId}` – update editable profile fields
- `POST /employees/{employeeId}/merge` – merge duplicate employee into target

## Intake & Referral
- `POST /referrals` – create referral (`intake_path=referral|direct_engagement`)
- `GET /referrals/{referralId}` – get referral detail
- `POST /referrals/{referralId}/triage` – set risk/triage outcome
- `POST /referrals/{referralId}/assign` – assign coordinator
- `POST /referrals/{referralId}/status` – transition referral status

## Cases, Plans, Notes
- `POST /cases` – create case (from referral or direct engagement)
- `GET /cases/{caseId}` – get case
- `POST /cases/{caseId}/status` – transition case status
- `POST /development-plans` – create plan
- `GET /development-plans/{planId}` – get plan
- `POST /development-plans/{planId}/version` – create new plan version
- `POST /progress-notes` – create draft progress note
- `POST /progress-notes/{noteId}/finalize` – finalize note
- `POST /progress-notes/{noteId}/amend` – create amended version

## Partners, Surveys, Assessments, Presentations
- `POST /partners` – create/update partner
- `POST /partners/{partnerId}/fidelity-assessments` – submit partner fidelity review
- `POST /feedback-surveys/submit` – submit employee feedback
- `POST /needs-assessments` – submit needs assessment
- `POST /resource-presentations` – create resource presentation
- `POST /resource-presentations/{presentationId}/attendance` – upsert attendance

## Communications
- `POST /consents` – capture/update channel consent
- `POST /campaigns` – create campaign draft
- `POST /campaigns/{campaignId}/schedule` – schedule campaign
- `POST /campaigns/{campaignId}/send` – request send
- `POST /webhooks/email` – email provider callbacks
- `POST /webhooks/sms` – SMS provider callbacks

## Analytics, Export, Admin
- `GET /kpis` – query KPI aggregates with cohort filters
- `POST /exports` – create export/print packet job
- `GET /exports/{exportId}` – retrieve export metadata + signed URL
- `GET /tenant-config` – get tenant config
- `PATCH /tenant-config` – update tenant config

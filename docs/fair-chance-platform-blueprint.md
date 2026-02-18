# Fair Chance Workforce Enablement Platform Blueprint

## 1) Product Scope
A configurable, AI-assisted platform that allows organizations to run fair chance employment support programs at scale.

### Primary Outcomes
- Enable low-friction employee self-referral into support programs.
- Improve quality and consistency of individualized development plans.
- Streamline case documentation while preserving compliance and auditability.
- Measure impact with tenant-specific KPIs and dashboards.
- Support both **referral-based** and **direct-engagement** workflows.

---

## 2) Core Modules

## A. Employee Intake & Referral System

### Functional Requirements
- Multi-entry referral creation:
  - Employee self-entry
  - Coordinator entry
  - Manager entry
- Mobile-first intake form (multilingual + accessibility support).
- Consent workflow (data sharing, communication preferences, policy acknowledgments).
- Risk/urgency triage questionnaire.
- Multi-select need categories (food, clothing, housing, legal, mental health/wellness, transportation).
- External booking integration (Microsoft Bookings first).
- Duplicate detection + manual merge for employee identity cleanup.
- Referral archive workflow for completed/aged referrals.

### AI in Workflow
- Smart form assist: simplify and clarify questions in plain language.
- Referral summarization for coordinator handoff.
- Priority scoring recommendation with transparent rationale.
- Duplicate candidate suggestions based on fuzzy name/contact matching.

### Key Data Captured
- First and last names separately (plus display name if needed).
- Employment status and role details.
- Barriers to stability/advancement.
- Preferred communication channel.
- Consent records and timestamps.
- Referral source type and submitting user.

---

## B. Individualized Development Plan Builder

### Functional Requirements
- Plan templates by barrier type and company policy.
- SMART goals with milestones and due dates.
- Goals mapped to referral support categories.
- Resource linking (internal and community services).
- Approval workflow (employee + coordinator sign-off).
- Plan revision history and version comparison.

### AI in Workflow
- Draft plan generator from intake + prior sessions.
- Goal quality checks (specific, measurable, realistic).
- Suggested interventions ranked by expected impact.
- Bias checks and language checks on plan narratives.

### Outputs
- Development plan document with owner, actions, and timeline.
- Weekly/monthly task checklists.
- Milestone confidence score and risk flags.

---

## C. Case Management + Documentation

### Functional Requirements
- Caseload-scoped timeline (meetings, notes, referrals, tasks, outcomes).
- Structured progress notes with traditional case-note fields.
- Progress note **start date** and interaction date/time.
- Meeting Location + Next Meeting Location dropdown options: Office, Garage, Newberry, Community, Phone, Video, Text, Email.
- Required note fields: meeting location, areas of need (multi-select), employee report, coordinator observations, short/long-term goals, follow-up actions, and meeting summary.
- Follow-up reminders and escalation rules.
- Document uploads with metadata and retention policy tags.
- Internal collaboration notes (role-restricted).
- Archive employee profiles and restore when needed.

### AI in Workflow
- Meeting note summarization with action extraction.
- Next-best-action recommendations.
- Progress trend detection (on-track / at-risk / stalled).
- Auto-generated outreach drafts (SMS/email templates).

### Compliance Features
- Immutable audit logs.
- Role-based redaction for sensitive notes.
- Signed consent linkage for any shared records.
- Record merge lineage logs (when duplicate employees are merged).

---

## D. Partnerships, Assessments, and Feedback

### Functional Requirements
- External partner registry and MOU/agreement tracking.
- Partner fidelity scoring over time.
- Periodic employee feedback collection (service quality/satisfaction).
- Needs assessments with configurable cadence and question sets.
- Resource presentations/events with attendance tracking.

### AI in Workflow
- Feedback sentiment aggregation.
- Needs-assessment trend summaries.
- Partner risk flags when fidelity scores decline.

---

## E. Program Analytics & KPI Dashboard

### Functional Requirements
- KPI library + custom metric builder.
- Separate scorecards for program-level and coordinator-level KPIs.
- Cohort segmentation (site, role, tenure, risk profile, intervention type).
- Time-series trends and benchmark comparisons.
- Exportable executive reports and board-ready summaries.
- Print/export outputs for plans and progress notes.

### Standard KPI Categories
- Intake funnel: referral volume, completion rate, time-to-assignment.
- Engagement: session cadence, no-show rate, task completion.
- Outcomes: retention, promotion, wage growth, incident reduction.
- Service impact: resource utilization, successful referrals, resolution rate.
- Program scope additions:
  - employee-reported stability improvement (housing/transportation/finances)
  - resource conversion after referral/direct engagement
  - support area utilization and participants per support area
  - partner fidelity rate (agreement and service standard adherence)
  - program awareness rate (periodic internal survey)
  - documentation completion/submission rate
- Coordinator scorecard focus:
  - referral response rate
  - employee engagement count
  - resource presentation count
  - time allocation to direct service
  - employee feedback/satisfaction
  - documentation completion/submission rate

### AI in Workflow
- Narrative analytics (“what changed this quarter?”).
- Driver analysis suggestions (leading indicators).
- Forecasting for capacity and case load.

---

## F. Customization Layer per Company

### Configuration Surface
- Tenant-specific forms and fields.
- Program taxonomies and service categories.
- KPI definitions and scorecards.
- Branding, communication templates, and language packs.
- Policy-based workflow logic (SLAs, escalations, approvals).
- Survey/assessment instruments and cadence settings.

### Isolation Model
- Strict tenant data partitioning.
- Tenant-level encryption keys (if required).
- Company-scoped AI retrieval context.

---

## 3) End-to-End User Journey

1. Employee/coordinator/manager submits referral (or direct engagement is created).
2. System validates consent and triages urgency.
3. Coordinator receives AI-generated summary and recommended first steps.
4. Initial meeting conducted; AI drafts development plan.
5. Plan reviewed and approved collaboratively.
6. Ongoing case interactions logged with structured notes and start dates.
7. Feedback and periodic needs assessments are collected.
8. Program manager monitors KPI dashboard and operational load.
9. Company admin customizes policies/KPIs and exports impact reports.

---

## 4) Multi-Tenant Architecture (MVP)

### Frontend Apps
- Employee Portal
- Coordinator Console
- Program Admin Dashboard

### Backend Services
- Identity & Access Service
- Intake & Case Service
- Plan Management Service
- Survey/Assessment Service
- Partner Management Service
- Analytics Service
- Notification Service (email/SMS + campaign support)
- AI Orchestration Service

### Data & AI
- PostgreSQL for transactional data
- Object storage for files
- Analytics store (optional in MVP)
- Vector index for tenant-approved knowledge base

---

## 5) Security, Privacy, and Responsible AI

### Security Baseline
- SSO + MFA for staff roles.
- RBAC with least privilege + caseload-based row access.
- Encryption in transit and at rest.
- Full audit logging for sensitive actions.

### Responsible AI Controls
- Human-in-the-loop for plan approval and high-impact decisions.
- Prompt + response logging for review.
- PII masking in model context where feasible.
- Explainable recommendation traces.
- Hallucination checks against trusted sources.

---

## 6) MVP Milestones

### Phase 1 (0–8 weeks)
- Intake portal + case assignment + structured progress notes.
- Development plan templates and baseline KPI dashboard.
- AI summaries for intake + meeting notes.
- Caseload filtering and document upload.

### Phase 2 (8–16 weeks)
- Full plan generator + recommendation engine.
- KPI customization layer + cohort analytics.
- Feedback/needs assessment workflows.
- Alerting and workflow automations.

### Phase 3 (16+ weeks)
- Predictive insights, staffing/capacity forecasts.
- External partner integrations (community providers, HRIS, booking systems).
- Partner fidelity scorecards and advanced outcome impact modeling.

---

## 7) Commercial Packaging Suggestion

### Pricing Model
- Base platform subscription per tenant.
- Seat-based pricing for coordinators/admins.
- Usage-based add-on for AI processing volume and messaging campaigns.

### Offer Tiers
- Essential: intake + case management + baseline KPIs.
- Professional: plan automation + feedback/assessment + customizable dashboards.
- Enterprise: advanced analytics, API integrations, dedicated support.

# AI Workflow Design for Fair Chance Workforce Enablement

## 1) AI Workflow: Intake & Referral Triage Assistant

### Trigger
Employee/coordinator/manager submits a referral or direct-engagement intake.

### Inputs
- Intake form responses
- Tenant-specific triage rubric
- Available coordinator capacity
- Candidate duplicate records (for merge recommendations)

### AI Tasks
1. Produce plain-language intake summary.
2. Predict urgency tier with confidence score.
3. Recommend first-touch actions.
4. Flag missing critical info.
5. Suggest probable duplicate records for human review.

### Human Review
Coordinator confirms or overrides urgency, assignment, and any merge action.

---

## 2) AI Workflow: Development Plan Drafting

### Trigger
Initial case meeting completed and intake validated.

### Inputs
- Intake summary
- Meeting notes/transcript
- Tenant templates + policy constraints
- Employee goals and barriers
- Support categories selected in referral

### AI Tasks
1. Draft SMART goals.
2. Map interventions/resources per goal.
3. Create milestone timeline.
4. Suggest risk mitigations for likely blockers.

### Human Review
Coordinator edits and approves final plan with employee.

---

## 3) AI Workflow: Progress Notes Co-Pilot

### Trigger
After case interactions (meeting, call, follow-up, resource presentation).

### Inputs
- Raw notes or transcript
- Existing plan and open actions
- Required structured fields (including start date)

### AI Tasks
1. Summarize interaction.
2. Extract action items with owner + due date.
3. Detect sentiment/progress trend.
4. Suggest next outreach draft.
5. Validate note completeness against required fields.

### Human Review
Coordinator confirms summary and submits note.

---

## 4) AI Workflow: Feedback, Assessment, and Partner Insight

### Trigger
New survey submission, needs assessment completion, or partner fidelity update.

### Inputs
- Employee feedback scores/comments
- Needs-assessment payload
- Partner scorecard trends

### AI Tasks
1. Detect trend shifts and risks.
2. Draft intervention opportunities.
3. Propose preventive focus areas.
4. Produce partner performance summaries.

### Human Review
Program manager validates insights before operational changes.

---

## 5) AI Workflow: KPI Narrative Analyst

### Trigger
Scheduled analytics refresh (daily/weekly/monthly).

### Inputs
- KPI time series
- Cohort cuts
- Prior interventions and operational changes

### AI Tasks
1. Explain major KPI shifts.
2. Highlight leading indicators.
3. Suggest operational experiments.
4. Draft executive summary text.

### Human Review
Program manager validates narrative before distribution.

---

## 6) AI Workflow: Communication Drafting Assistant

### Trigger
Coordinator/program manager creates a campaign or one-off outreach.

### Inputs
- Consent rules
- Audience segment filters
- Program events and due actions

### AI Tasks
1. Draft email/SMS content in approved tone.
2. Localize reading level and language.
3. Flag consent/privacy violations before send.

### Human Review
User approves content and delivery schedule.

---

## Responsible AI Guardrails
- Never auto-close or deny services without human decision.
- Show evidence snippets for each recommendation.
- Log all prompts and model outputs for audit.
- Use tenant-specific context boundaries to avoid data leakage.
- Redact sensitive identifiers when possible.
- Require human approval before outbound communications are sent.

---

## Prompt Template Example: Plan Drafting

```text
System:
You are a fair chance workforce case planning assistant. Create supportive, non-judgmental development plans.

Rules:
- Use only provided case context.
- Output SMART goals with measurable milestones.
- Include at least one risk mitigation per goal.
- Align each goal to one support category.
- Do not make legal or medical determinations.

Context:
- Tenant policies: {{tenant_policy}}
- Employee intake summary: {{intake_summary}}
- Latest meeting notes: {{meeting_notes}}
- Support categories: {{support_categories}}
- Resource catalog: {{resource_catalog}}

Output JSON Schema:
{
  "plan_summary": "string",
  "goals": [
    {
      "title": "string",
      "category": "string",
      "milestones": ["string"],
      "target_date": "YYYY-MM-DD",
      "success_metric": "string",
      "recommended_resources": ["string"],
      "risks": ["string"],
      "mitigations": ["string"]
    }
  ]
}
```

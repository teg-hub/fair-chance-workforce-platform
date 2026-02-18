# AI Workflow Design for Fair Chance Workforce Enablement

## 1) AI Workflow: Intake Triage Assistant

### Trigger
Employee submits a self-referral intake form.

### Inputs
- Intake form responses
- Tenant-specific triage rubric
- Available case worker capacity

### AI Tasks
1. Produce plain-language intake summary.
2. Predict urgency tier with confidence score.
3. Recommend first-touch actions.
4. Flag missing critical info.

### Human Review
Case worker confirms or overrides urgency and assignment.

---

## 2) AI Workflow: Development Plan Drafting

### Trigger
Initial case meeting completed and intake validated.

### Inputs
- Intake summary
- Meeting notes/transcript
- Tenant templates + policy constraints
- Employee goals and barriers

### AI Tasks
1. Draft SMART goals.
2. Map interventions/resources per goal.
3. Create milestone timeline.
4. Suggest risk mitigations for likely blockers.

### Human Review
Case worker edits and approves final plan with employee.

---

## 3) AI Workflow: Session Documentation Co-Pilot

### Trigger
After case interactions (meeting, call, follow-up).

### Inputs
- Raw notes or transcript
- Existing plan and open actions

### AI Tasks
1. Summarize interaction.
2. Extract action items with owner + due date.
3. Detect sentiment/progress trend.
4. Suggest next outreach draft.

### Human Review
Case worker confirms summary and pushes tasks.

---

## 4) AI Workflow: KPI Narrative Analyst

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

## Responsible AI Guardrails
- Never auto-close or deny services without human decision.
- Show evidence snippets for each recommendation.
- Log all prompts and model outputs for audit.
- Use tenant-specific context boundaries to avoid data leakage.
- Redact sensitive identifiers when possible.

---

## Prompt Template Example: Plan Drafting

```text
System:
You are a fair chance workforce case planning assistant. Create supportive, non-judgmental development plans.

Rules:
- Use only provided case context.
- Output SMART goals with measurable milestones.
- Include at least one risk mitigation per goal.
- Do not make legal or medical determinations.

Context:
- Tenant policies: {{tenant_policy}}
- Employee intake summary: {{intake_summary}}
- Latest meeting notes: {{meeting_notes}}
- Resource catalog: {{resource_catalog}}

Output JSON Schema:
{
  "plan_summary": "string",
  "goals": [
    {
      "title": "string",
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

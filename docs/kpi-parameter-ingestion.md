# KPI Parameter Ingestion (Founder-Provided Slide)

This document translates the founder-provided KPI slide into explicit, implementation-ready KPI definitions.

## Program-Level KPI Parameters

1. **Improvement in employee-reported stability over time**
   - Coverage areas: housing, transportation, finances
   - Measurement: change from baseline to current periodic survey/assessment score
2. **Resource access conversion rate**
   - Measurement: % of employees who access resources after referral/direct engagement
3. **Utilization rate**
   - Measurement: participants per support area and total utilization
4. **Partners meeting service standards/agreements**
   - Measurement: % of active partners meeting MOU/service-delivery criteria
5. **Program awareness rate**
   - Measurement: % of employees aware of program via periodic internal survey

## Coordinator-Level KPI Parameters

1. **Response rate to employee referrals**
   - Measurement: % of assigned referrals responded to within SLA
2. **Number of employee engagements**
   - Measurement: count of documented employee interactions
3. **Number of resource presentations**
   - Measurement: count of presentations delivered/facilitated
4. **Time allocation**
   - Measurement: share of coordinator time in direct service vs admin
5. **Employee feedback/satisfaction**
   - Measurement: average satisfaction score from employee feedback instruments
6. **Completion/submission rates of documentation**
   - Measurement: required progress notes finalized on time

## Build Incorporation Notes

- All KPI definitions above are represented in `docs/sample-kpi-config.json` under `programKpis` and `coordinatorKpis`.
- KPI cohort slicing should include support category, intake path, location, and risk level.
- Survey-backed KPIs (awareness, satisfaction, stability) require recurring survey cadence configuration.

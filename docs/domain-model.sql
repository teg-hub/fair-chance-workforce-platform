-- Canonical starter domain model for Fair Chance Workforce Enablement Platform (PostgreSQL)
-- Aligns to referral + direct engagement, case-centric workflows, and caseload-scoped operations.

CREATE TABLE tenants (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE users (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  email TEXT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('employee', 'coordinator', 'manager', 'program_manager', 'company_admin', 'platform_admin')),
  external_auth_id TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, email)
);

CREATE TABLE employees (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_user_id UUID REFERENCES users(id),
  external_hris_id TEXT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  preferred_language TEXT NOT NULL DEFAULT 'en',
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'leave', 'terminated')),
  merged_into_employee_id UUID REFERENCES employees(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, external_hris_id)
);

CREATE TABLE employee_merge_events (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  surviving_employee_id UUID NOT NULL REFERENCES employees(id),
  merged_employee_id UUID NOT NULL REFERENCES employees(id),
  merged_by_user_id UUID NOT NULL REFERENCES users(id),
  merge_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE referrals (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  intake_path TEXT NOT NULL CHECK (intake_path IN ('referral', 'direct_engagement')),
  source_type TEXT NOT NULL CHECK (source_type IN ('employee_self', 'manager', 'coordinator', 'hr', 'anonymous_other')),
  employee_id UUID REFERENCES employees(id),
  submitted_by_user_id UUID REFERENCES users(id),
  referral_status TEXT NOT NULL CHECK (referral_status IN ('submitted', 'triaged', 'assigned', 'contacted', 'in_progress', 'converted_to_case', 'closed', 'cancelled', 'archived')),
  risk_level TEXT NOT NULL CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
  support_category_codes TEXT[] NOT NULL DEFAULT '{}',
  preferred_contact_channel TEXT,
  booking_provider TEXT,
  booking_reference TEXT,
  intake_payload JSONB NOT NULL,
  ai_summary TEXT,
  ai_priority_score NUMERIC(5,2),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  assigned_coordinator_id UUID REFERENCES users(id)
);

CREATE TABLE cases (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_id UUID NOT NULL REFERENCES employees(id),
  referral_id UUID REFERENCES referrals(id),
  assigned_coordinator_id UUID NOT NULL REFERENCES users(id),
  case_status TEXT NOT NULL DEFAULT 'open' CHECK (case_status IN ('open', 'active_support', 'paused', 'closed')),
  opened_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  closed_at TIMESTAMPTZ
);

CREATE TABLE development_plans (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  case_id UUID NOT NULL REFERENCES cases(id),
  employee_id UUID NOT NULL REFERENCES employees(id),
  owner_coordinator_id UUID NOT NULL REFERENCES users(id),
  status TEXT NOT NULL CHECK (status IN ('draft', 'active', 'paused', 'completed', 'archived')),
  version INTEGER NOT NULL DEFAULT 1,
  title TEXT,
  start_date DATE,
  target_end_date DATE,
  goals_json JSONB NOT NULL DEFAULT '[]',
  ai_generated BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE progress_notes (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_id UUID NOT NULL REFERENCES employees(id),
  case_id UUID NOT NULL REFERENCES cases(id),
  coordinator_id UUID NOT NULL REFERENCES users(id),
  note_type TEXT NOT NULL CHECK (note_type IN ('intake', 'coaching_session', 'resource_referral', 'crisis', 'follow_up')),
  note_start_date DATE NOT NULL,
  interaction_at TIMESTAMPTZ NOT NULL,
  meeting_location TEXT NOT NULL CHECK (meeting_location IN ('office', 'garage', 'newberry', 'community', 'phone', 'video', 'text', 'email')),
  areas_of_need_codes TEXT[] NOT NULL DEFAULT '{}',
  employee_report TEXT,
  coordinator_observations TEXT,
  short_term_goals TEXT,
  long_term_goals TEXT,
  employee_follow_up_actions TEXT,
  coordinator_follow_up_actions TEXT,
  referrals_made TEXT,
  next_meeting_at TIMESTAMPTZ,
  next_meeting_location TEXT CHECK (next_meeting_location IN ('office', 'garage', 'newberry', 'community', 'phone', 'video', 'text', 'email')),
  summary_of_meeting TEXT,
  structured_json JSONB NOT NULL DEFAULT '{}',
  status TEXT NOT NULL CHECK (status IN ('draft', 'final', 'amended')),
  version INTEGER NOT NULL DEFAULT 1,
  prior_note_id UUID REFERENCES progress_notes(id),
  ai_summary TEXT,
  action_items JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE external_partners (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  name TEXT NOT NULL,
  support_category_codes TEXT[] NOT NULL DEFAULT '{}',
  mou_reference TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE partner_fidelity_assessments (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  partner_id UUID NOT NULL REFERENCES external_partners(id),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  score_total INTEGER NOT NULL CHECK (score_total BETWEEN 0 AND 100),
  notes TEXT,
  created_by_user_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE employee_feedback_surveys (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_id UUID NOT NULL REFERENCES employees(id),
  survey_version TEXT NOT NULL,
  response_payload JSONB NOT NULL,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE needs_assessments (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_id UUID NOT NULL REFERENCES employees(id),
  conducted_by_user_id UUID NOT NULL REFERENCES users(id),
  assessment_date DATE NOT NULL,
  support_category_codes TEXT[] NOT NULL DEFAULT '{}',
  assessment_payload JSONB NOT NULL,
  ai_summary TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE resource_presentations (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  title TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ NOT NULL,
  presenter_user_id UUID REFERENCES users(id),
  partner_id UUID REFERENCES external_partners(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE resource_presentation_attendance (
  resource_presentation_id UUID NOT NULL REFERENCES resource_presentations(id),
  employee_id UUID NOT NULL REFERENCES employees(id),
  status TEXT NOT NULL CHECK (status IN ('registered', 'attended', 'no_show', 'cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (resource_presentation_id, employee_id)
);

CREATE TABLE consents (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_id UUID NOT NULL REFERENCES employees(id),
  channel TEXT NOT NULL CHECK (channel IN ('email', 'sms', 'in_app')),
  status TEXT NOT NULL CHECK (status IN ('opt_in', 'opt_out')),
  captured_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE campaigns (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  created_by_user_id UUID NOT NULL REFERENCES users(id),
  channel TEXT NOT NULL CHECK (channel IN ('email', 'sms', 'in_app')),
  audience_filter JSONB NOT NULL,
  message_template_id UUID,
  message_body TEXT,
  status TEXT NOT NULL CHECK (status IN ('draft', 'scheduled', 'sending', 'paused', 'sent', 'cancelled')),
  scheduled_for TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE message_deliveries (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  campaign_id UUID NOT NULL REFERENCES campaigns(id),
  employee_id UUID NOT NULL REFERENCES employees(id),
  status TEXT NOT NULL CHECK (status IN ('queued', 'sent', 'delivered', 'failed', 'suppressed')),
  provider_message_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE uploaded_documents (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_id UUID REFERENCES employees(id),
  referral_id UUID REFERENCES referrals(id),
  case_id UUID REFERENCES cases(id),
  development_plan_id UUID REFERENCES development_plans(id),
  progress_note_id UUID REFERENCES progress_notes(id),
  storage_uri TEXT NOT NULL,
  document_type TEXT,
  metadata JSONB,
  uploaded_by_user_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE kpi_definitions (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  key TEXT NOT NULL,
  name TEXT NOT NULL,
  level TEXT NOT NULL CHECK (level IN ('program', 'coordinator')),
  description TEXT,
  formula JSONB NOT NULL,
  target_value NUMERIC(12,4),
  aggregation_window TEXT NOT NULL DEFAULT 'monthly',
  UNIQUE (tenant_id, key)
);

CREATE TABLE kpi_measurements (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kpi_definition_id UUID NOT NULL REFERENCES kpi_definitions(id),
  coordinator_id UUID REFERENCES users(id),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  value NUMERIC(12,4) NOT NULL,
  dimension_payload JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tenant_configs (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id),
  config_version INTEGER NOT NULL DEFAULT 1,
  timezone TEXT NOT NULL DEFAULT 'America/New_York',
  quiet_hours_start TIME NOT NULL DEFAULT '21:00',
  quiet_hours_end TIME NOT NULL DEFAULT '08:00',
  intake_form_schema JSONB NOT NULL,
  workflow_rules JSONB NOT NULL,
  notification_templates JSONB NOT NULL,
  survey_instruments JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE audit_events (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  actor_user_id UUID REFERENCES users(id),
  event_name TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID NOT NULL,
  event_payload JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_referrals_tenant_status ON referrals(tenant_id, referral_status);
CREATE INDEX idx_referrals_assignee ON referrals(tenant_id, assigned_coordinator_id);
CREATE INDEX idx_cases_assignee_status ON cases(tenant_id, assigned_coordinator_id, case_status);
CREATE INDEX idx_progress_notes_case ON progress_notes(tenant_id, case_id, created_at);
CREATE INDEX idx_partner_fidelity_period ON partner_fidelity_assessments(tenant_id, partner_id, period_start, period_end);
CREATE INDEX idx_feedback_submitted_at ON employee_feedback_surveys(tenant_id, submitted_at);
CREATE INDEX idx_kpi_measurements_period ON kpi_measurements(tenant_id, period_start, period_end);
CREATE INDEX idx_audit_entity ON audit_events(tenant_id, entity_type, entity_id, created_at);

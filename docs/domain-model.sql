-- Starter domain model for Fair Chance Workforce Enablement Platform (PostgreSQL)
-- Updated to include uploaded scope parameters (multi-entry referrals, structured progress notes,
-- partner fidelity, assessments, feedback, and communication campaigns).

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

CREATE TABLE employee_profiles (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_user_id UUID NOT NULL REFERENCES users(id),
  employee_external_id TEXT,
  archived_at TIMESTAMPTZ,
  archived_by_user_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, employee_user_id)
);

CREATE TABLE employee_merge_events (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  surviving_employee_profile_id UUID NOT NULL REFERENCES employee_profiles(id),
  merged_employee_profile_id UUID NOT NULL REFERENCES employee_profiles(id),
  merged_by_user_id UUID NOT NULL REFERENCES users(id),
  merge_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE referrals (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_profile_id UUID REFERENCES employee_profiles(id),
  source_type TEXT NOT NULL CHECK (source_type IN ('employee_self_entry', 'coordinator_entry', 'manager_entry')),
  submitted_by_user_id UUID REFERENCES users(id),
  referral_status TEXT NOT NULL CHECK (referral_status IN ('submitted', 'triaged', 'assigned', 'closed', 'archived')),
  urgency_level TEXT CHECK (urgency_level IN ('low', 'medium', 'high', 'critical')),
  preferred_contact_channel TEXT,
  booking_provider TEXT,
  booking_reference TEXT,
  intake_payload JSONB NOT NULL,
  ai_summary TEXT,
  ai_priority_score NUMERIC(5,2),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  assigned_coordinator_id UUID REFERENCES users(id)
);

CREATE TABLE referral_support_categories (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  key TEXT NOT NULL,
  label TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE (tenant_id, key)
);

CREATE TABLE referral_category_assignments (
  referral_id UUID NOT NULL REFERENCES referrals(id),
  category_id UUID NOT NULL REFERENCES referral_support_categories(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (referral_id, category_id)
);

CREATE TABLE development_plans (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  referral_id UUID REFERENCES referrals(id),
  employee_profile_id UUID NOT NULL REFERENCES employee_profiles(id),
  owner_coordinator_id UUID NOT NULL REFERENCES users(id),
  status TEXT NOT NULL CHECK (status IN ('draft', 'in_review', 'active', 'completed', 'archived')),
  version INTEGER NOT NULL DEFAULT 1,
  plan_summary TEXT,
  ai_generated BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE plan_goals (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  development_plan_id UUID NOT NULL REFERENCES development_plans(id),
  category_id UUID REFERENCES referral_support_categories(id),
  title TEXT NOT NULL,
  description TEXT,
  target_date DATE,
  status TEXT NOT NULL CHECK (status IN ('not_started', 'in_progress', 'blocked', 'completed')),
  success_metric TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE progress_notes (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_profile_id UUID NOT NULL REFERENCES employee_profiles(id),
  referral_id UUID REFERENCES referrals(id),
  development_plan_id UUID REFERENCES development_plans(id),
  coordinator_id UUID NOT NULL REFERENCES users(id),
  note_start_date DATE NOT NULL,
  interaction_at TIMESTAMPTZ NOT NULL,
  engagement_type TEXT NOT NULL CHECK (engagement_type IN ('meeting', 'call', 'sms', 'email', 'checkin', 'resource_referral', 'presentation')),
  goals_addressed TEXT,
  direct_service_efforts TEXT,
  external_partnership_connections TEXT,
  narrative_note TEXT,
  ai_summary TEXT,
  action_items JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE external_partners (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  name TEXT NOT NULL,
  service_categories JSONB,
  mou_reference TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE partner_fidelity_assessments (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  partner_id UUID NOT NULL REFERENCES external_partners(id),
  assessment_date DATE NOT NULL,
  fidelity_score NUMERIC(5,2) NOT NULL,
  notes TEXT,
  created_by_user_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE employee_feedback_surveys (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_profile_id UUID NOT NULL REFERENCES employee_profiles(id),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  survey_type TEXT NOT NULL,
  score_payload JSONB NOT NULL,
  comments TEXT
);

CREATE TABLE needs_assessments (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_profile_id UUID NOT NULL REFERENCES employee_profiles(id),
  conducted_by_user_id UUID NOT NULL REFERENCES users(id),
  assessment_date DATE NOT NULL,
  assessment_payload JSONB NOT NULL,
  priority_recommendations JSONB,
  ai_summary TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE resource_presentations (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  title TEXT NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL,
  presenter_user_id UUID REFERENCES users(id),
  partner_id UUID REFERENCES external_partners(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE resource_presentation_attendance (
  resource_presentation_id UUID NOT NULL REFERENCES resource_presentations(id),
  employee_profile_id UUID NOT NULL REFERENCES employee_profiles(id),
  attended BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (resource_presentation_id, employee_profile_id)
);

CREATE TABLE generated_communications (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  created_by_user_id UUID NOT NULL REFERENCES users(id),
  channel TEXT NOT NULL CHECK (channel IN ('email', 'sms')),
  campaign_name TEXT,
  message_body TEXT NOT NULL,
  audience_filter JSONB,
  status TEXT NOT NULL CHECK (status IN ('draft', 'scheduled', 'sent', 'cancelled')),
  scheduled_for TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE uploaded_documents (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_profile_id UUID REFERENCES employee_profiles(id),
  referral_id UUID REFERENCES referrals(id),
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
  intake_form_schema JSONB NOT NULL,
  workflow_rules JSONB NOT NULL,
  notification_templates JSONB NOT NULL,
  survey_instruments JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_referrals_tenant_status ON referrals(tenant_id, referral_status);
CREATE INDEX idx_referrals_tenant_assignee ON referrals(tenant_id, assigned_coordinator_id);
CREATE INDEX idx_progress_notes_tenant_employee ON progress_notes(tenant_id, employee_profile_id);
CREATE INDEX idx_development_plans_tenant_status ON development_plans(tenant_id, status);
CREATE INDEX idx_partner_fidelity_tenant_partner_date ON partner_fidelity_assessments(tenant_id, partner_id, assessment_date);
CREATE INDEX idx_feedback_tenant_date ON employee_feedback_surveys(tenant_id, submitted_at);
CREATE INDEX idx_kpi_measurements_period ON kpi_measurements(tenant_id, period_start, period_end);

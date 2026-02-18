-- Starter domain model for Fair Chance Workforce Enablement Platform (PostgreSQL)

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

CREATE TABLE employee_referrals (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  employee_user_id UUID REFERENCES users(id),
  referral_status TEXT NOT NULL CHECK (referral_status IN ('submitted', 'triaged', 'assigned', 'closed')),
  urgency_level TEXT NOT NULL CHECK (urgency_level IN ('low', 'medium', 'high', 'critical')),
  preferred_contact_channel TEXT,
  intake_payload JSONB NOT NULL,
  ai_summary TEXT,
  ai_priority_score NUMERIC(5,2),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  assigned_case_worker_id UUID REFERENCES users(id)
);

CREATE TABLE development_plans (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  referral_id UUID NOT NULL REFERENCES employee_referrals(id),
  employee_user_id UUID NOT NULL REFERENCES users(id),
  owner_case_worker_id UUID NOT NULL REFERENCES users(id),
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
  title TEXT NOT NULL,
  description TEXT,
  target_date DATE,
  status TEXT NOT NULL CHECK (status IN ('not_started', 'in_progress', 'blocked', 'completed')),
  success_metric TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE case_interactions (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  referral_id UUID NOT NULL REFERENCES employee_referrals(id),
  case_worker_id UUID NOT NULL REFERENCES users(id),
  interaction_type TEXT NOT NULL CHECK (interaction_type IN ('meeting', 'call', 'sms', 'email', 'checkin', 'resource_referral')),
  occurred_at TIMESTAMPTZ NOT NULL,
  notes TEXT,
  ai_summary TEXT,
  action_items JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE kpi_definitions (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  key TEXT NOT NULL,
  name TEXT NOT NULL,
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
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_referrals_tenant_status ON employee_referrals(tenant_id, referral_status);
CREATE INDEX idx_plans_tenant_status ON development_plans(tenant_id, status);
CREATE INDEX idx_interactions_tenant_referral ON case_interactions(tenant_id, referral_id);
CREATE INDEX idx_kpi_measurements_period ON kpi_measurements(tenant_id, period_start, period_end);

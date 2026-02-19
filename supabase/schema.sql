create table if not exists users (
  id text primary key,
  tenant_id text not null,
  email text not null,
  role text not null
);

create table if not exists employees (
  id text primary key,
  tenant_id text not null,
  first_name text not null,
  last_name text not null,
  email text
);

create table if not exists referrals (
  id uuid primary key,
  tenant_id text not null,
  intake_path text not null check (intake_path in ('referral','direct_engagement')),
  source_type text not null,
  employee_id text not null,
  referral_status text not null,
  risk_level text not null,
  support_category_codes text[] not null,
  submitted_by_user_id text not null,
  assigned_coordinator_id text,
  submitted_at timestamptz not null,
  first_response_at timestamptz
);

create table if not exists cases (
  id uuid primary key,
  tenant_id text not null,
  employee_id text not null,
  referral_id uuid,
  assigned_coordinator_id text not null,
  case_status text not null,
  opened_at timestamptz not null
);

create table if not exists progress_notes (
  id uuid primary key,
  tenant_id text not null,
  employee_id text not null,
  case_id uuid not null,
  coordinator_id text not null,
  note_type text not null,
  note_start_date date not null,
  interaction_at timestamptz not null,
  meeting_location text not null,
  areas_of_need_codes text[] not null,
  summary_of_meeting text,
  status text not null,
  created_at timestamptz not null
);

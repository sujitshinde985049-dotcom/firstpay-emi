-- Phase 5: Multi-tenant Patsanstha organization foundation.
-- All authenticated users are temporarily treated as Super Admin until
-- FirstPay role claims and tenant membership policies are introduced.

create extension if not exists pgcrypto;

create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  registration_number text not null check (length(trim(registration_number)) > 0),
  registration_date date not null,
  address text not null check (length(trim(address)) > 0),
  city text not null check (length(trim(city)) > 0),
  district text not null check (length(trim(district)) > 0),
  state text not null check (length(trim(state)) > 0),
  pincode text not null check (pincode ~ '^[0-9]{6}$'),
  contact_person text not null check (length(trim(contact_person)) > 0),
  mobile text not null check (mobile ~ '^[6-9][0-9]{9}$'),
  email text not null check (email ~* '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),
  status text not null default 'active' check (status in ('active', 'inactive')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists organizations_registration_number_ci_key
  on public.organizations (lower(trim(registration_number)));

create index if not exists organizations_tenant_id_idx
  on public.organizations (tenant_id);

create index if not exists organizations_status_idx
  on public.organizations (status);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists organizations_set_updated_at on public.organizations;
create trigger organizations_set_updated_at
before update on public.organizations
for each row execute function public.set_updated_at();

alter table public.organizations enable row level security;

-- Temporary Phase 5 policy: every authenticated FirstPay account is treated as
-- a Super Admin. Replace this policy with JWT role and tenant membership checks
-- when role management is implemented.
drop policy if exists organizations_super_admin_all on public.organizations;
create policy organizations_super_admin_all
on public.organizations
for all
to authenticated
using (true)
with check (true);

grant select, insert, update on public.organizations to authenticated;
revoke all on public.organizations from anon;

comment on table public.organizations is
  'Patsanstha tenants managed by FirstPay; tenant-scoped RLS follows role management.';
comment on column public.organizations.tenant_id is
  'Stable tenant boundary identifier for future tenant isolation policies.';
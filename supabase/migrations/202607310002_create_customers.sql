-- Phase 6: Customer management foundation for mandate systems.
create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete restrict,
  full_name text not null check (length(trim(full_name)) > 0),
  mobile text not null check (mobile ~ '^[6-9][0-9]{9}$'),
  email text null check (email is null or email ~* '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),
  date_of_birth date not null,
  gender text not null check (gender in ('male','female','other','preferNotToSay')),
  aadhaar_number text null check (aadhaar_number is null or aadhaar_number ~ '^[0-9]{12}$'),
  pan_number text null check (pan_number is null or pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'),
  address text not null check (length(trim(address)) > 0),
  city text not null check (length(trim(city)) > 0),
  district text not null check (length(trim(district)) > 0),
  state text not null check (length(trim(state)) > 0),
  pincode text not null check (pincode ~ '^[0-9]{6}$'),
  account_holder_name text not null check (length(trim(account_holder_name)) > 0),
  bank_name text not null check (length(trim(bank_name)) > 0),
  branch_name text not null check (length(trim(branch_name)) > 0),
  account_number text not null check (account_number ~ '^[0-9]{9,18}$'),
  ifsc_code text not null check (ifsc_code ~ '^[A-Z]{4}0[A-Z0-9]{6}$'),
  account_type text not null check (account_type in ('savings','current')),
  upi_id text,
  status text not null default 'active' check (status in ('active','inactive')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists customers_organization_mobile_key on public.customers (organization_id, mobile);
create index if not exists customers_organization_id_idx on public.customers (organization_id);
create index if not exists customers_status_idx on public.customers (status);
create index if not exists customers_full_name_ci_idx on public.customers (lower(full_name));
drop trigger if exists customers_set_updated_at on public.customers;
create trigger customers_set_updated_at before update on public.customers for each row execute function public.set_updated_at();
alter table public.customers enable row level security;
-- Temporary Phase 6 policy: authenticated users are treated as administrators.
-- Replace with organization membership predicates when tenant roles are implemented.
drop policy if exists customers_authenticated_all on public.customers;
create policy customers_authenticated_all on public.customers for all to authenticated using (true) with check (true);
grant select, insert, update on public.customers to authenticated;
revoke all on public.customers from anon;
comment on table public.customers is 'Customers owned by one Patsanstha and shared by future mandate modules.';
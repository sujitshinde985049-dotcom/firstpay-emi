-- Phase 7: UPI AutoPay mandate draft workflow. No gateway integration.
create table if not exists public.upi_mandates (
 id uuid primary key default gen_random_uuid(), reference_number uuid not null unique default gen_random_uuid(),
 organization_id uuid not null references public.organizations(id) on delete restrict,
 customer_id uuid not null references public.customers(id) on delete restrict,
 bank_account text not null check(length(trim(bank_account))>0), upi_id text not null check(upi_id ~ '^[A-Za-z0-9._-]{2,256}@[A-Za-z][A-Za-z0-9.-]{1,63}$'),
 mandate_amount numeric(14,2) not null check(mandate_amount>0), maximum_amount numeric(14,2) not null check(maximum_amount>0 and maximum_amount>=mandate_amount),
 frequency text not null check(frequency in ('daily','weekly','monthly','quarterly','halfYearly','yearly')),
 start_date date not null, end_date date not null check(end_date>=start_date), purpose text not null check(length(trim(purpose))>0),
 status text not null default 'draft' check(status in ('draft','pending','approved','rejected','cancelled')),
 gateway_reference text, webhook_status text, webhook_payload jsonb, last_webhook_at timestamptz,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists upi_mandates_organization_id_idx on public.upi_mandates(organization_id);
create index if not exists upi_mandates_customer_id_idx on public.upi_mandates(customer_id);
create index if not exists upi_mandates_status_idx on public.upi_mandates(status);
create index if not exists upi_mandates_reference_number_idx on public.upi_mandates(reference_number);
drop trigger if exists upi_mandates_set_updated_at on public.upi_mandates;
create trigger upi_mandates_set_updated_at before update on public.upi_mandates for each row execute function public.set_updated_at();
alter table public.upi_mandates enable row level security;
drop policy if exists upi_mandates_authenticated_all on public.upi_mandates;
create policy upi_mandates_authenticated_all on public.upi_mandates for all to authenticated using(true) with check(true);
grant select,insert,update on public.upi_mandates to authenticated;revoke all on public.upi_mandates from anon;
comment on table public.upi_mandates is 'UPI AutoPay mandate workflow records; gateway and webhook processing are not implemented.';
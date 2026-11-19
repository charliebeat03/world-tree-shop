-- World Tree initial schema. Review and apply to a dedicated Supabase project only.
create extension if not exists pgcrypto;

create type public.product_status as enum ('available', 'check_availability', 'sold_out', 'hidden');
create type public.combo_status as enum ('available', 'sold_out', 'hidden');

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.categories(id) on delete restrict,
  name text not null,
  slug text not null unique,
  description text not null default '',
  status public.product_status not null default 'check_availability',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  storage_path text not null,
  alt_text text not null default '',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique(product_id, storage_path)
);

-- Tariff labels deliberately preserve the owner's names; currencies/payment rails
-- must be clarified before displaying currency symbols in production.
create table public.pricing_options (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code in ('Zelle','IBAN','Bizum','Posta','Reales','MXN','PDO','Rublos')),
  display_name text not null,
  sort_order integer not null default 0,
  is_active boolean not null default true
);

create table public.product_prices (
  product_id uuid not null references public.products(id) on delete cascade,
  pricing_option_id uuid not null references public.pricing_options(id) on delete restrict,
  amount numeric(12,2) not null check (amount >= 0),
  updated_at timestamptz not null default now(),
  primary key(product_id, pricing_option_id)
);

create table public.combos (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text not null default '',
  status public.combo_status not null default 'available',
  starts_at timestamptz,
  ends_at timestamptz,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at is null or starts_at is null or ends_at > starts_at)
);

create table public.combo_images (
  id uuid primary key default gen_random_uuid(),
  combo_id uuid not null references public.combos(id) on delete cascade,
  storage_path text not null,
  alt_text text not null default '',
  sort_order integer not null default 0,
  unique(combo_id, storage_path)
);

create table public.combo_items (
  combo_id uuid not null references public.combos(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete restrict,
  quantity numeric(10,2) not null check (quantity > 0),
  primary key(combo_id, product_id)
);

create table public.combo_prices (
  combo_id uuid not null references public.combos(id) on delete cascade,
  pricing_option_id uuid not null references public.pricing_options(id) on delete restrict,
  amount numeric(12,2) not null check (amount >= 0),
  updated_at timestamptz not null default now(),
  primary key(combo_id, pricing_option_id)
);

-- Province/municipality availability is controlled by the owner, not hard-coded in UI.
create table public.provinces (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  is_enabled boolean not null default false,
  sort_order integer not null default 0
);

create table public.municipalities (
  id uuid primary key default gen_random_uuid(),
  province_id uuid not null references public.provinces(id) on delete restrict,
  name text not null,
  is_enabled boolean not null default false,
  sort_order integer not null default 0,
  unique(province_id, name)
);

-- Admin access is derived from this table, never from user-editable metadata.
create table public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','maintenance')),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create or replace function public.is_active_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.admin_users a
    where a.user_id = (select auth.uid()) and a.is_active = true
  );
$$;
revoke all on function public.is_active_admin() from public;
grant execute on function public.is_active_admin() to anon, authenticated;

alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.pricing_options enable row level security;
alter table public.product_prices enable row level security;
alter table public.combos enable row level security;
alter table public.combo_images enable row level security;
alter table public.combo_items enable row level security;
alter table public.combo_prices enable row level security;
alter table public.provinces enable row level security;
alter table public.municipalities enable row level security;
alter table public.admin_users enable row level security;

-- Public read is limited to active, visible catalog rows.
create policy "public read active categories" on public.categories for select to anon, authenticated using (is_active or public.is_active_admin());
create policy "public read visible products" on public.products for select to anon, authenticated using (status <> 'hidden' or public.is_active_admin());
create policy "public read product images" on public.product_images for select to anon, authenticated using (
  exists(select 1 from public.products p where p.id = product_id and (p.status <> 'hidden' or public.is_active_admin()))
);
create policy "public read active pricing options" on public.pricing_options for select to anon, authenticated using (is_active or public.is_active_admin());
create policy "public read prices for visible products" on public.product_prices for select to anon, authenticated using (
  exists(select 1 from public.products p where p.id = product_id and (p.status <> 'hidden' or public.is_active_admin()))
);
create policy "public read visible combos" on public.combos for select to anon, authenticated using (status <> 'hidden' or public.is_active_admin());
create policy "public read combo images" on public.combo_images for select to anon, authenticated using (
  exists(select 1 from public.combos c where c.id = combo_id and (c.status <> 'hidden' or public.is_active_admin()))
);
create policy "public read combo items" on public.combo_items for select to anon, authenticated using (
  exists(select 1 from public.combos c where c.id = combo_id and (c.status <> 'hidden' or public.is_active_admin()))
);
create policy "public read combo prices" on public.combo_prices for select to anon, authenticated using (
  exists(select 1 from public.combos c where c.id = combo_id and (c.status <> 'hidden' or public.is_active_admin()))
);
create policy "read enabled provinces" on public.provinces for select to anon, authenticated using (is_enabled or public.is_active_admin());
create policy "read enabled municipalities" on public.municipalities for select to anon, authenticated using (is_enabled or public.is_active_admin());

-- No anonymous writes. All authenticated writes require an active admin record.
create policy "admin manage categories" on public.categories for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin manage products" on public.products for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin manage product images" on public.product_images for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin manage pricing options" on public.pricing_options for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin manage product prices" on public.product_prices for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin manage combos" on public.combos for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin manage combo images" on public.combo_images for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin manage combo items" on public.combo_items for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin manage combo prices" on public.combo_prices for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin manage provinces" on public.provinces for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin manage municipalities" on public.municipalities for all to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
create policy "admin read own admin record" on public.admin_users for select to authenticated using (user_id = (select auth.uid()));
create policy "owner manage admin users" on public.admin_users for all to authenticated using (
  exists(select 1 from public.admin_users a where a.user_id = (select auth.uid()) and a.role = 'owner' and a.is_active)
) with check (
  exists(select 1 from public.admin_users a where a.user_id = (select auth.uid()) and a.role = 'owner' and a.is_active)
);

insert into public.categories(name,slug,sort_order) values
('Cárnicos','carnicos',1),
('Productos lácteos','productos-lacteos',2),
('Granos','granos',3),
('Confituras','confituras',4),
('Aseo','aseo',5),
('Otros','otros',6);

insert into public.pricing_options(code,display_name,sort_order) values
('Zelle','Zelle',1),('IBAN','IBAN',2),('Bizum','Bizum',3),('Posta','Posta',4),
('Reales','Reales',5),('MXN','MXN',6),('PDO','PDO',7),('Rublos','Rublos',8);

insert into public.provinces(name,is_enabled,sort_order) values ('Santiago de Cuba',true,1);
insert into public.municipalities(province_id,name,is_enabled,sort_order)
select p.id, m.name, true, m.ord
from public.provinces p
cross join (values
 ('Santiago de Cuba',1),('Contramaestre',2),('Palma Soriano',3),('San Luis',4),
 ('Songo-La Maya',5),('Segundo Frente',6),('Tercer Frente',7),('Guamá',8),('Mella',9)
) as m(name,ord)
where p.name = 'Santiago de Cuba';

-- No orders or recipient identity details are persisted in this initial schema.
-- When image storage is configured, add storage.objects policies restricted to admin writes.

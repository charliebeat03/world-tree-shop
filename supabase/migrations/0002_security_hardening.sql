-- World Tree 0.2: security hardening and administrative helpers.
-- Apply after 0001_initial_schema.sql in a dedicated Supabase project.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;

-- Avoid a SECURITY DEFINER helper in the exposed public schema.
create or replace function private.is_active_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select (select auth.uid()) is not null
     and exists (
       select 1
       from public.admin_users a
       where a.user_id = (select auth.uid())
         and a.is_active = true
     );
$$;

create or replace function private.is_active_owner()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select (select auth.uid()) is not null
     and exists (
       select 1
       from public.admin_users a
       where a.user_id = (select auth.uid())
         and a.role = 'owner'
         and a.is_active = true
     );
$$;

revoke all on function private.is_active_admin() from public, anon;
revoke all on function private.is_active_owner() from public, anon;
grant execute on function private.is_active_admin() to authenticated;
grant execute on function private.is_active_owner() to authenticated;

-- Replace policies which called the original exposed helper.
-- Public reads do not call an exposed SECURITY DEFINER helper. Admin reads are
-- granted separately by the authenticated admin policies below.
drop policy if exists "public read active categories" on public.categories;
drop policy if exists "public read visible products" on public.products;
drop policy if exists "public read product images" on public.product_images;
drop policy if exists "public read active pricing options" on public.pricing_options;
drop policy if exists "public read prices for visible products" on public.product_prices;
drop policy if exists "public read visible combos" on public.combos;
drop policy if exists "public read combo images" on public.combo_images;
drop policy if exists "public read combo items" on public.combo_items;
drop policy if exists "public read combo prices" on public.combo_prices;
drop policy if exists "read enabled provinces" on public.provinces;
drop policy if exists "read enabled municipalities" on public.municipalities;

create policy "public read active categories" on public.categories for select to anon, authenticated using (is_active);
create policy "public read visible products" on public.products for select to anon, authenticated using (status <> 'hidden');
create policy "public read product images" on public.product_images for select to anon, authenticated using (exists(select 1 from public.products p where p.id = product_id and p.status <> 'hidden'));
create policy "public read active pricing options" on public.pricing_options for select to anon, authenticated using (is_active);
create policy "public read prices for visible products" on public.product_prices for select to anon, authenticated using (exists(select 1 from public.products p where p.id = product_id and p.status <> 'hidden'));
create policy "public read visible combos" on public.combos for select to anon, authenticated using (status <> 'hidden');
create policy "public read combo images" on public.combo_images for select to anon, authenticated using (exists(select 1 from public.combos c where c.id = combo_id and c.status <> 'hidden'));
create policy "public read combo items" on public.combo_items for select to anon, authenticated using (exists(select 1 from public.combos c where c.id = combo_id and c.status <> 'hidden'));
create policy "public read combo prices" on public.combo_prices for select to anon, authenticated using (exists(select 1 from public.combos c where c.id = combo_id and c.status <> 'hidden'));
create policy "read enabled provinces" on public.provinces for select to anon, authenticated using (is_enabled);
create policy "read enabled municipalities" on public.municipalities for select to anon, authenticated using (is_enabled);

drop policy if exists "admin manage categories" on public.categories;
drop policy if exists "admin manage products" on public.products;
drop policy if exists "admin manage product images" on public.product_images;
drop policy if exists "admin manage pricing options" on public.pricing_options;
drop policy if exists "admin manage product prices" on public.product_prices;
drop policy if exists "admin manage combos" on public.combos;
drop policy if exists "admin manage combo images" on public.combo_images;
drop policy if exists "admin manage combo items" on public.combo_items;
drop policy if exists "admin manage combo prices" on public.combo_prices;
drop policy if exists "admin manage provinces" on public.provinces;
drop policy if exists "admin manage municipalities" on public.municipalities;
drop policy if exists "owner manage admin users" on public.admin_users;

create policy "admin manage categories" on public.categories for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());
create policy "admin manage products" on public.products for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());
create policy "admin manage product images" on public.product_images for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());
create policy "admin manage pricing options" on public.pricing_options for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());
create policy "admin manage product prices" on public.product_prices for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());
create policy "admin manage combos" on public.combos for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());
create policy "admin manage combo images" on public.combo_images for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());
create policy "admin manage combo items" on public.combo_items for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());
create policy "admin manage combo prices" on public.combo_prices for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());
create policy "admin manage provinces" on public.provinces for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());
create policy "admin manage municipalities" on public.municipalities for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());

-- Prevent recursive evaluation of admin_users policies through a private helper.
drop policy if exists "admin read own admin record" on public.admin_users;
create policy "admin read own admin record" on public.admin_users for select to authenticated
using (user_id = (select auth.uid()));

create policy "owner manage admin users" on public.admin_users for all to authenticated
using (private.is_active_owner()) with check (private.is_active_owner());

-- Keep updated_at accurate on editable entities.
create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists products_set_updated_at on public.products;
create trigger products_set_updated_at before update on public.products
for each row execute function private.set_updated_at();

drop trigger if exists combos_set_updated_at on public.combos;
create trigger combos_set_updated_at before update on public.combos
for each row execute function private.set_updated_at();

-- Province policy is intentionally configuration-driven.
-- Santiago de Cuba remains the only enabled province initially.
update public.provinces set is_enabled = (name = 'Santiago de Cuba');
update public.municipalities m
set is_enabled = (p.name = 'Santiago de Cuba')
from public.provinces p
where p.id = m.province_id;

-- Correct canonical municipality names. No other province is enabled.
update public.municipalities set name = 'Segundo Frente'
where name in ('II Frente', '2do Frente');
update public.municipalities set name = 'Tercer Frente'
where name in ('III Frente', '3er Frente');

-- Admins must be created by an owner through a trusted server-side workflow.
-- Never grant anon INSERT/UPDATE/DELETE on admin_users.

-- The original exposed helper is no longer referenced by any policy.
drop function if exists public.is_active_admin();

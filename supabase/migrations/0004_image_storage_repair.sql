-- 0004: repair and standardize image storage/database policies.
-- Apply after 0001, 0002 and 0003 in Supabase SQL Editor.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('world-tree-products','world-tree-products',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set
  public=true,
  file_size_limit=5242880,
  allowed_mime_types=array['image/jpeg','image/png','image/webp'];

-- Public storefront can read objects; only active admins can mutate them.
drop policy if exists "public read World Tree product images" on storage.objects;
create policy "public read World Tree product images"
on storage.objects for select to anon, authenticated
using (bucket_id='world-tree-products');

drop policy if exists "admins upload World Tree product images" on storage.objects;
create policy "admins upload World Tree product images"
on storage.objects for insert to authenticated
with check (bucket_id='world-tree-products' and private.is_active_admin());

drop policy if exists "admins update World Tree product images" on storage.objects;
create policy "admins update World Tree product images"
on storage.objects for update to authenticated
using (bucket_id='world-tree-products' and private.is_active_admin())
with check (bucket_id='world-tree-products' and private.is_active_admin());

drop policy if exists "admins delete World Tree product images" on storage.objects;
create policy "admins delete World Tree product images"
on storage.objects for delete to authenticated
using (bucket_id='world-tree-products' and private.is_active_admin());

-- Explicitly reassert metadata row permissions for product and combo images.
drop policy if exists "admin manage product images" on public.product_images;
create policy "admin manage product images" on public.product_images for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());

drop policy if exists "admin manage combo images" on public.combo_images;
create policy "admin manage combo images" on public.combo_images for all to authenticated
using (private.is_active_admin()) with check (private.is_active_admin());

drop policy if exists "public read product images" on public.product_images;
create policy "public read product images" on public.product_images for select to anon, authenticated
using (exists(select 1 from public.products p where p.id=product_id and p.status <> 'hidden'));

drop policy if exists "public read combo images" on public.combo_images;
create policy "public read combo images" on public.combo_images for select to anon, authenticated
using (exists(select 1 from public.combos c where c.id=combo_id and c.status <> 'hidden'));

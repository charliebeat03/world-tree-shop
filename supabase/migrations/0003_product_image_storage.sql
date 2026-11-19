-- 0003: product image storage bucket and access rules.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('world-tree-products','world-tree-products',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "public read World Tree product images" on storage.objects;
create policy "public read World Tree product images"
on storage.objects for select to anon, authenticated
using (bucket_id = 'world-tree-products');

drop policy if exists "admins upload World Tree product images" on storage.objects;
create policy "admins upload World Tree product images"
on storage.objects for insert to authenticated
with check (bucket_id = 'world-tree-products' and private.is_active_admin());

drop policy if exists "admins update World Tree product images" on storage.objects;
create policy "admins update World Tree product images"
on storage.objects for update to authenticated
using (bucket_id = 'world-tree-products' and private.is_active_admin())
with check (bucket_id = 'world-tree-products' and private.is_active_admin());

drop policy if exists "admins delete World Tree product images" on storage.objects;
create policy "admins delete World Tree product images"
on storage.objects for delete to authenticated
using (bucket_id = 'world-tree-products' and private.is_active_admin());

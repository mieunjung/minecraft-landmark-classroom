create table if not exists public.landmark_posts (
  id uuid primary key default gen_random_uuid(),
  author text not null check (char_length(author) between 1 and 24),
  title text not null check (char_length(title) between 1 and 70),
  body text not null check (char_length(body) between 1 and 1200),
  image_url text check (image_url is null or char_length(image_url) <= 2048),
  author_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

create index if not exists landmark_posts_created_at_idx
  on public.landmark_posts (created_at desc);

alter table public.landmark_posts enable row level security;

grant select on public.landmark_posts to anon, authenticated;
grant insert, delete on public.landmark_posts to authenticated;

drop policy if exists "Anyone can read landmark posts" on public.landmark_posts;
create policy "Anyone can read landmark posts"
  on public.landmark_posts for select
  using (true);

drop policy if exists "Anonymous students can create limited posts" on public.landmark_posts;
create policy "Anonymous students can create limited posts"
  on public.landmark_posts for insert
  to authenticated
  with check (
    author_id = (select auth.uid())
    and (
      select count(*)
      from public.landmark_posts existing
      where existing.author_id = (select auth.uid())
        and existing.created_at > now() - interval '1 hour'
    ) < 5
  );

drop policy if exists "Students can delete their own posts" on public.landmark_posts;
create policy "Students can delete their own posts"
  on public.landmark_posts for delete
  to authenticated
  using (author_id = (select auth.uid()));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'landmark-post-images',
  'landmark-post-images',
  true,
  8388608,
  array['image/jpeg']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Students can upload their own post images" on storage.objects;
create policy "Students can upload their own post images"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'landmark-post-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Students can delete their own post images" on storage.objects;
create policy "Students can delete their own post images"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'landmark-post-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

do $$
begin
  alter publication supabase_realtime add table public.landmark_posts;
exception
  when duplicate_object then null;
end
$$;

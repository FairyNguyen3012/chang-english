-- Chặng English: admin content tables for Supabase.
-- Run this whole file once in Supabase → SQL Editor. It is safe to run again.
-- Everyone can READ the content with the public anon key.
-- Only users listed in public.admins can WRITE (enforced by Row Level Security).

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.custom_topics (
  id text primary key check (id ~ '^[a-z0-9_-]{2,24}$'),
  name text not null check (char_length(name) between 1 and 80),
  vi text check (char_length(vi) <= 80),
  sort int not null default 0,
  hidden boolean not null default false,
  updated_at timestamptz not null default now()
);

-- Words added to any topic/lesson. A row with "replaces" edits (or, with hidden = true, hides)
-- the built-in word of that name in the same lesson.
create table if not exists public.custom_words (
  id bigint generated always as identity primary key,
  topic text not null check (topic ~ '^[a-z0-9_-]{2,24}$'),
  lesson int not null check (lesson between 0 and 59),
  sort int not null default 0,
  w text not null check (char_length(w) between 1 and 80),
  ipa text check (char_length(ipa) <= 80),
  pos text check (char_length(pos) <= 30),
  vi text check (char_length(vi) <= 160),
  ctx text check (char_length(ctx) <= 160),
  ex text check (char_length(ex) <= 300),
  lv text check (lv in ('A1','A2','B1','B2','C1')),
  replaces text check (char_length(replaces) <= 80),
  hidden boolean not null default false,
  updated_at timestamptz not null default now()
);
create index if not exists custom_words_topic_lesson on public.custom_words (topic, lesson);

-- Per-lesson CEFR level and listening paragraph overrides.
create table if not exists public.lesson_meta (
  topic text not null check (topic ~ '^[a-z0-9_-]{2,24}$'),
  lesson int not null check (lesson between 0 and 59),
  lv text check (lv in ('A1','A2','B1','B2','C1')),
  paragraph text check (char_length(paragraph) <= 3000),
  updated_at timestamptz not null default now(),
  primary key (topic, lesson)
);

-- App-wide settings, e.g. key = 'notice', value = {"text": "...", "on": true, "level": "info"}.
create table if not exists public.app_settings (
  key text primary key check (key ~ '^[a-z_]{2,40}$'),
  value jsonb not null default '{}'::jsonb check (pg_column_size(value) < 8000),
  updated_at timestamptz not null default now()
);

-- Helper used by the policies. SECURITY DEFINER so it can read admins under RLS.
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

alter table public.admins        enable row level security;
alter table public.custom_topics enable row level security;
alter table public.custom_words  enable row level security;
alter table public.lesson_meta   enable row level security;
alter table public.app_settings  enable row level security;

-- admins: a signed-in user may only see their own row; nobody can change it from the app.
drop policy if exists "admins see self" on public.admins;
create policy "admins see self" on public.admins for select to authenticated using (user_id = auth.uid());

do $$
declare t text;
begin
  foreach t in array array['custom_topics','custom_words','lesson_meta','app_settings'] loop
    execute format('drop policy if exists "public read" on public.%I', t);
    execute format('create policy "public read" on public.%I for select to anon, authenticated using (true)', t);
    execute format('drop policy if exists "admin insert" on public.%I', t);
    execute format('create policy "admin insert" on public.%I for insert to authenticated with check (public.is_admin())', t);
    execute format('drop policy if exists "admin update" on public.%I', t);
    execute format('create policy "admin update" on public.%I for update to authenticated using (public.is_admin()) with check (public.is_admin())', t);
    execute format('drop policy if exists "admin delete" on public.%I', t);
    execute format('create policy "admin delete" on public.%I for delete to authenticated using (public.is_admin())', t);
  end loop;
end $$;

grant select on public.custom_topics, public.custom_words, public.lesson_meta, public.app_settings to anon, authenticated;
grant insert, update, delete on public.custom_topics, public.custom_words, public.lesson_meta, public.app_settings to authenticated;
grant select on public.admins to authenticated;

-- Learner accounts: each learner reads and writes only their own progress row (same as accounts.sql).

create table if not exists public.user_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb check (pg_column_size(data) < 1000000),
  updated_at timestamptz not null default now()
);

alter table public.user_progress enable row level security;

drop policy if exists "own progress read" on public.user_progress;
create policy "own progress read" on public.user_progress for select to authenticated using (user_id = auth.uid());
drop policy if exists "own progress insert" on public.user_progress;
create policy "own progress insert" on public.user_progress for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "own progress update" on public.user_progress;
create policy "own progress update" on public.user_progress for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "own progress delete" on public.user_progress;
create policy "own progress delete" on public.user_progress for delete to authenticated using (user_id = auth.uid());

revoke all on public.user_progress from anon;
grant select, insert, update, delete on public.user_progress to authenticated;

-- LAST STEP: after creating your user in Authentication → Users, make it an admin.
-- Replace the email below with yours, then run just this statement.
-- insert into public.admins (user_id) select id from auth.users where email = 'you@example.com' on conflict do nothing;

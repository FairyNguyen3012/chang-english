-- Chặng English: learner accounts (progress sync).
-- Run this once in Supabase → SQL Editor. It is safe to run again.
-- Each signed-in learner can read and write only their own row.

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

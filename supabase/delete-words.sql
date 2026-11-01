-- Chặng English: lets admins delete built-in words (not just hide them).
-- Run once in Supabase → SQL Editor. Safe to run again.
alter table public.custom_words add column if not exists deleted boolean not null default false;

-- Chặng English: allow the C2 level in admin content.
-- Run once in Supabase → SQL Editor if your project was set up before C2 existed. Safe to run again.
alter table public.custom_words drop constraint if exists custom_words_lv_check;
alter table public.custom_words add constraint custom_words_lv_check check (lv in ('A1','A2','B1','B2','C1','C2'));
alter table public.lesson_meta drop constraint if exists lesson_meta_lv_check;
alter table public.lesson_meta add constraint lesson_meta_lv_check check (lv in ('A1','A2','B1','B2','C1','C2'));

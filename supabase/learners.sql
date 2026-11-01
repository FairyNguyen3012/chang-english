-- Chặng English: the Learners tab on the admin page.
-- Run once in Supabase → SQL Editor. Safe to run again. Only admins can call it.

create or replace function public.list_learners()
returns table (user_id uuid, email text, name text, joined_at timestamptz, last_sign_in timestamptz,
               confirmed boolean, is_admin boolean, xp int, lessons_done int, stories int, synced_at timestamptz)
language plpgsql stable security definer set search_path = public, auth as $$
#variable_conflict use_column
begin
  if not public.is_admin() then raise exception 'not allowed' using errcode = '42501'; end if;
  return query
    select u.id,
           u.email::text,
           coalesce(u.raw_user_meta_data->>'name', '')::text,
           u.created_at,
           u.last_sign_in_at,
           u.email_confirmed_at is not null,
           exists (select 1 from public.admins a where a.user_id = u.id),
           case when (p.data->>'xp') ~ '^[0-9]{1,9}$' then (p.data->>'xp')::int else 0 end,
           (select count(*)::int from jsonb_each_text(case when jsonb_typeof(p.data->'done') = 'object' then p.data->'done' else '{}'::jsonb end) d
             where d.value ~ '^[0-9]+(\.[0-9]+)?$' and d.value::numeric >= 0.8),
           case when jsonb_typeof(p.data->'stories') = 'array' then jsonb_array_length(p.data->'stories') else 0 end,
           p.updated_at
    from auth.users u
    left join public.user_progress p on p.user_id = u.id
    order by u.created_at desc;
end $$;

revoke all on function public.list_learners() from public, anon;
grant execute on function public.list_learners() to authenticated;

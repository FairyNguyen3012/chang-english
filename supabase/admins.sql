-- Chặng English: manage the admin list from the app's admin page.
-- Run once in Supabase → SQL Editor. Safe to run again.
-- Only signed-in admins can call these functions; everyone else is refused.

create or replace function public.list_admins()
returns table (user_id uuid, email text, added_at timestamptz)
language plpgsql stable security definer set search_path = public, auth as $$
begin
  if not public.is_admin() then raise exception 'not allowed' using errcode = '42501'; end if;
  return query
    select a.user_id, u.email::text, a.created_at
    from public.admins a join auth.users u on u.id = a.user_id
    order by a.created_at;
end $$;

-- The person must already have an account (signed up in the app, or created in Authentication → Users).
create or replace function public.add_admin(p_email text)
returns text
language plpgsql security definer set search_path = public, auth as $$
declare uid uuid;
begin
  if not public.is_admin() then raise exception 'not allowed' using errcode = '42501'; end if;
  select id into uid from auth.users where lower(email) = lower(trim(p_email)) limit 1;
  if uid is null then return 'no_user'; end if;
  if exists (select 1 from public.admins where user_id = uid) then return 'already'; end if;
  insert into public.admins (user_id) values (uid);
  return 'added';
end $$;

-- An admin cannot remove themselves, and the last admin can never be removed.
create or replace function public.remove_admin(p_user uuid)
returns text
language plpgsql security definer set search_path = public, auth as $$
begin
  if not public.is_admin() then raise exception 'not allowed' using errcode = '42501'; end if;
  if p_user = auth.uid() then return 'self'; end if;
  if (select count(*) from public.admins) <= 1 then return 'last'; end if;
  delete from public.admins where user_id = p_user;
  return 'removed';
end $$;

revoke all on function public.list_admins() from public, anon;
revoke all on function public.add_admin(text) from public, anon;
revoke all on function public.remove_admin(uuid) from public, anon;
grant execute on function public.list_admins() to authenticated;
grant execute on function public.add_admin(text) to authenticated;
grant execute on function public.remove_admin(uuid) to authenticated;

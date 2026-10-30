# Admin area

The admin area lets you manage the app's content with an account ID (email) and password. It uses a free [Supabase](https://supabase.com) project: Supabase stores the content and handles sign-in, and Row Level Security makes sure only admins can change anything.

Open it at `https://<user>.github.io/<repo>/#admin`, or use the **Quản trị nội dung** link at the bottom of the home page.

## One-time setup (about 10 minutes)

1. Create a free project at [supabase.com](https://supabase.com).
2. Open **SQL Editor**, paste the whole of [`supabase/setup.sql`](supabase/setup.sql) and press **Run**.
3. Open **Authentication → Users → Add user → Create new user**. Enter the email you will use as your account ID and a strong password, tick **Auto Confirm User**, and create the user.
4. In the SQL Editor, run the last statement of `setup.sql` with your email:

   ```sql
   insert into public.admins (user_id) select id from auth.users where email = 'you@example.com' on conflict do nothing;
   ```

5. Open **Project Settings → API** (or **API Keys**) and copy the **Project URL** and the **anon** / **publishable** key. Never use the `service_role` or secret key.
6. Put them in [`supabase/config.json`](supabase/config.json):

   ```json
   { "url": "https://xxxx.supabase.co", "anonKey": "eyJ… or sb_publishable_…" }
   ```

7. Rebuild and push:

   ```bash
   python3 scripts/build.py
   ```

   ```bash
   git add -A && git commit -m "Connect Supabase" && git push
   ```

8. Recommended: in **Authentication → Providers → Email**, turn off **Allow new users to sign up**, so nobody else can create accounts.

To try the admin area before step 6, you can paste the URL and key into the form on the admin page. That connection is saved only in your browser, and learners won't see your content until you complete steps 6–7.

## What you can do

- **Words (Từ vựng):** pick a topic and lesson, then add words one by one or import many at once (`word|IPA|pos|meaning|context|example`, one per line). Built-in words can be edited or hidden. Choose **+ New lesson** to add a lesson to a topic.
- **Paragraph & level (Đoạn văn & bậc):** change a lesson's CEFR level and its listening paragraph.
- **Topics (Chủ đề):** create new topics, rename or hide any topic.
- **Notice (Thông báo):** show a message on every learner's home page.

Learners receive changes the next time they open the site. Changes never affect anyone's saved progress.

## Security

- Your password is sent only to Supabase over HTTPS and is never stored by the app. The session token is kept in `sessionStorage` and ends when you close the tab.
- The anon key in the page is public by design. The database only accepts writes from users listed in `public.admins` (Row Level Security in `setup.sql`).
- After 3 failed sign-ins, the form makes you wait before trying again; Supabase also rate-limits sign-ins.

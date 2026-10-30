# Chặng English

An English learning web app for Vietnamese learners. The whole app is one static file (`index.html`), so it runs on any static host, including GitHub Pages. An optional Supabase project adds an admin area for managing content.

## Features

- **Grammar by CEFR level:** 12 lessons from A1 to C2, each with formulas, audio examples and a 5-question test.
- **Vocabulary by topic:** 40 topics × 12 lessons × 10 words (4,800 words) with IPA, Vietnamese meaning, collocation and example sentence. Every lesson has a CEFR level (A1–C1); paths are grouped from easy to hard and can be filtered by level.
- **Each vocabulary lesson** has three steps: flashcards → listening, speaking & writing (listen, dictation, shadowing, retell, sentence writing) → test. Lessons inside a level unlock in order at 80%; the first lesson of every level is open.
- **Tests** mix meaning, reverse, listening, spelling and gap-fill questions, then end with two speaking questions: play the model, record your voice, listen back and get scored (or check yourself where the microphone is unavailable).
- **Sentence writing:** write one sentence per lesson word; the app checks it, and inside Claude the AI corrects grammar and word use.
- **Review notebook:** every wrong answer is saved for later practice.
- **Story studio:** write stories with chosen topic words. Add photos as the setting for a topic; inside Claude the AI reads them, writes a story context, suggests a prompt and picks fitting words. The context is kept per topic so each new story continues the last one.
- **Garden XP:** a plant grows through six stages as you learn.
- **Interface in Vietnamese or English**, light/dark theme, three text sizes.
- **Learner accounts** (`#account`): sign up and sign in with email and password. Progress, XP, review notebook, sentences, stories and story context sync across devices; signing out clears them from the device. Includes password reset by email.
- **Admin area** (`#admin`): sign in with an account ID (email) and password to add topics and words, edit or hide built-in words, change lesson levels and paragraphs, and post a notice. See [ADMIN.md](ADMIN.md).

## Notes

- Without an account, progress, stories, photos and story context are saved in the learner's own browser (`localStorage` and IndexedDB). With an account, everything except photos also syncs to Supabase.
- Audio uses the device's built-in English voice.
- Recording and speaking scores need HTTPS and microphone permission; speech scoring works in Chrome and Edge.
- The AI features (story marking, model stories, photo context, sentence correction, VI ⇄ EN translation) only work when the app is opened inside Claude; on GitHub Pages they show a short notice and everything else works.
- Admin content from Supabase loads on the published website; the copy inside Claude cannot use the network.

## Project layout

- `src/index.html`: the app as authored (single file).
- `scripts/build.py`: wraps the app in a full HTML page, writes in the Supabase settings and adds a Content Security Policy pinned to the app's script hash.
- `supabase/setup.sql`: tables and Row Level Security for the admin area and learner accounts.
- `supabase/accounts.sql`: just the learner-account table, for projects set up before accounts existed.
- `supabase/config.json`: your Supabase project URL and anon key (both public by design).
- `index.html`: the built page that GitHub Pages serves. Do not edit it by hand.

After changing `src/index.html` or `supabase/config.json`, rebuild and commit:

```bash
python3 scripts/build.py
```

See [SECURITY.md](SECURITY.md) for the security measures.

## Deploy on GitHub Pages

Settings → Pages → Build and deployment → Source: **Deploy from a branch** → Branch: **main** / **(root)** → Save. The site appears at `https://<user>.github.io/<repo>/` within a minute or two.

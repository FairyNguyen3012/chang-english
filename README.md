# Chặng English

An English learning web app for Vietnamese learners. The whole app is one static file (`index.html`), so it runs on any static host, including GitHub Pages.

## Features

- **Grammar by CEFR level:** 12 lessons from A1 to C2, each with formulas, audio examples and a 5-question test.
- **Vocabulary by topic:** 30 topics × 12 lessons × 6 words (2,160 words) with IPA, Vietnamese meaning, collocation and example sentence.
- **Each vocabulary lesson** has three steps: flashcards → listening & speaking (listen, dictation, shadowing, retell) → test. Lessons unlock in order at 80%.
- **Review notebook:** every wrong answer is saved for later practice.
- **Story studio:** write your own story with chosen topic words; live word tracking, read-aloud and saved stories.
- **Garden XP:** a plant grows through six stages as you learn.
- **Interface in Vietnamese or English**, light/dark theme, three text sizes.

## Notes

- Progress and stories are saved in the learner's own browser (`localStorage`); there are no accounts.
- Audio uses the device's built-in English voice.
- Speaking scores use the browser's speech recognition (Chrome/Edge) and need HTTPS, which GitHub Pages provides.
- The AI features (story marking, model stories, VI ⇄ EN translation) only work when the app is opened inside Claude; on GitHub Pages they show a short notice and everything else works.

## Project layout

- `src/index.html`: the app as authored (single file).
- `scripts/build.py`: wraps the app in a full HTML page and adds a Content Security Policy pinned to the app's script hash.
- `index.html`: the built page that GitHub Pages serves. Do not edit it by hand.

After changing `src/index.html`, rebuild and commit both files:

```bash
python3 scripts/build.py
```

See [SECURITY.md](SECURITY.md) for the security measures.

## Deploy on GitHub Pages

Settings → Pages → Build and deployment → Source: **Deploy from a branch** → Branch: **main** / **(root)** → Save. The site appears at `https://<user>.github.io/<repo>/` within a minute or two.

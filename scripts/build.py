#!/usr/bin/env python3
"""Build the GitHub Pages copy of the app.

src/index.html is the app exactly as authored (also published as a Claude artifact,
which supplies its own page skeleton). This script wraps it in a complete HTML
document and adds a Content Security Policy whose script-src allows only the app's
own inline script, identified by its SHA-256 hash. Run it after every change:

    python3 scripts/build.py
"""
import base64
import hashlib
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "src" / "index.html"
OUT = ROOT / "index.html"

app = SRC.read_text(encoding="utf-8")

# Everything before the page header (title, metas, font links, styles) belongs in <head>.
split_at = app.index('<header class="top">')
head, body = app[:split_at], app[split_at:]

# The artifact host normally provides this small reset; a standalone page needs it itself.
reset = (
    "<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}"
    "body{margin:0}img{max-width:100%}</style>"
)

scripts = re.findall(r"<script>(.*?)</script>", body, flags=re.S)
if len(scripts) != 1:
    raise SystemExit(f"expected exactly one inline <script>, found {len(scripts)}")
digest = base64.b64encode(hashlib.sha256(scripts[0].encode("utf-8")).digest()).decode()

csp = "; ".join([
    "default-src 'none'",
    f"script-src 'sha256-{digest}'",
    # inline style attributes are used throughout the UI
    "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
    "font-src https://fonts.gstatic.com",
    "img-src 'self' data:",
    "connect-src 'none'",
    "media-src 'none'",
    "object-src 'none'",
    "frame-src 'none'",
    "worker-src 'none'",
    "base-uri 'none'",
    "form-action 'none'",
    "upgrade-insecure-requests",
])

page = (
    "<!doctype html>\n<html lang=\"vi\">\n<head>\n"
    "<meta charset=\"utf-8\">\n"
    "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,viewport-fit=cover\">\n"
    f"<meta http-equiv=\"Content-Security-Policy\" content=\"{csp}\">\n"
    f"{reset}\n{head.strip()}\n</head>\n<body>\n{body.strip()}\n</body>\n</html>\n"
)
OUT.write_text(page, encoding="utf-8")
print(f"wrote {OUT.relative_to(ROOT)} ({len(page):,} bytes), script sha256-{digest[:16]}…")

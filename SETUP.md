# Setup

Everything here goes into a repo named **exactly** `lakshitasethia` —
`github.com/lakshitasethia/lakshitasethia`. That magic repo's README is what shows
on your profile page.

Structure and scripts are adapted from
[gargibhardwaj24/gargibhardwaj24](https://github.com/gargibhardwaj24/gargibhardwaj24).

---

## What's already done

- `README.md` — filled in with your name, projects, links and stack
- `assets/skills.json` — radar axes tailored to your work (self-rated, edit freely)
- `assets/projects.json` — Luminae, Huygens, Wellora, Sanchay
- `assets/radar-*.svg`, `assets/card-*.svg` — generated locally, will regenerate on GitHub
- `.github/workflows/` — Metrics, Snake, Charts-and-cards, all pointed at `lakshitasethia`

## Still to fill in by hand

- The "Fun fact" bullet in the whoami section, if you want your own

---

## 1. The portrait

Already done, but here's how it was made and how to redo it.

`assets/me.png` is a **subject cutout** of `~/Downloads/githubpic.jpeg` — background
removed, alpha channel kept.

It is **gitignored on purpose**: only the dot-matrix SVGs are published, so the
full-resolution photo never becomes a downloadable file in a public repo. That means a
fresh clone can't regenerate the portrait until you put the photo back. Recreate it with
macOS Vision via `scripts/cutout.swift`:

```bash
swift scripts/cutout.swift ~/Downloads/githubpic.jpeg assets/me.png
```

The cutout matters. `dotify.py` treats alpha as a subject mask: nothing is drawn outside
it, and `--equalize` measures only you rather than a big grey wall. Without it the room
behind you renders as dots too and muddies the whole thing.

Then:

```bash
python3 scripts/dotify.py assets/me.png -o assets/portrait \
  --cols 100 --equalize --detail 0.5 --color --square --focus 0.52,0.5 --reveal
```

Open `preview.html` in a browser to check it, and use the **replay the load-in** button
to rewatch the scan-in.

Knobs worth knowing:

- **`--equalize` is the one that matters.** A lit face against dark hair spans a far
  wider range than the ~10 tones a dot ramp can show; without it the face blows out
  to a flat blob and the hair disappears.
- `--detail 0.5` puts facial structure back after equalising flattens it. Above ~1.0
  it gets noisy.
- `--cols` is the quality/size dial. 60 is chunky and abstract, 100 is the default
  here (~325 KB), 130 is sharper but pushes past 500 KB.
- `--square --focus 0.55,0.45` crops to 1:1 with the face centred, if the source isn't
  already square.
- `--square --focus 0.52,0.5` crops the 4:3 source to 1:1 around your face.
- `--circle` masks to a circle with a faded edge. Barely changes anything here, since
  the cutout already removed the corners.
- `--invert` if your subject is dark on a light background.

### `--color-shade` (a local change to dotify.py)

Upstream, `--color` writes a **single** `portrait.svg` for both themes, on the grounds
that photo colours don't depend on the theme. That breaks on a light page: your face is
brightly lit, dot radius scales with brightness, so GitHub's light theme got big
near-white dots on white and the portrait basically disappeared.

`dotify.py` here emits a **`-dark`/`-light` pair even in colour mode**, and the light one
multiplies every photo colour toward black by `--color-shade` (default `0.58`). Hue is
kept, ink comes back. The README swaps them with `<picture>` like every other asset.

`--color-shade 1.0` restores the upstream single-appearance behaviour. `0.45` is darker
and more legible but goes grey; `0.70` keeps more colour but is faint.

## 2. Push it

```bash
cd ~/lakshitasethia
git init && git branch -M main
git add -A && git commit -m "profile readme"
git remote add origin https://github.com/lakshitasethia/lakshitasethia.git
git push -u origin main
```

The repo must be **public** — the SVGs are loaded by URL, so a private repo shows
broken images on your profile.

## 3. Let Actions write to the repo

Repo → **Settings** → **Actions** → **General** → **Workflow permissions** →
**Read and write permissions** → Save.

Without this the Radar and Snake workflows fail on push.

## 4. Add the metrics token

`lowlighter/metrics` needs its own token — the built-in `GITHUB_TOKEN` can't read
profile data.

1. https://github.com/settings/tokens → **Generate new token (classic)**
2. Scope: **`read:user`**
3. Repo → **Settings** → **Secrets and variables** → **Actions** →
   **New repository secret** → name **`METRICS_TOKEN`**, paste the value

Fine-grained tokens don't work here; it has to be classic.

## 5. Kick off the workflows

Repo → **Actions** → enable workflows if prompted, then **Run workflow** on each:

| workflow | produces | lands in |
|---|---|---|
| **Metrics** | 3D isometric calendar, language mix, achievements | `assets/metrics.*.svg` on `main` |
| **Snake** | snake eating your contribution graph | the `output` branch |
| **Charts and cards** | both radars, stat card, project cards | `assets/radar*.svg`, `assets/card-*.svg` on `main` |

The snake images 404 until the Snake workflow has run once — that's expected.
After the first run they're on a schedule: metrics every 6h, snake every 12h,
radar daily.

---

## Tuning

### The radar

`assets/skills.json` is self-rated, 0-100. Five to eight axes reads best; past that
the labels crowd each other.

The second radar (`radar-langs`) comes from real language byte counts across your
public repos, so it needs no editing. Two knobs in `.github/workflows/radar.yml`:

- `--exclude` drops languages you don't want counted. HTML and CSS are excluded here —
  your front-end repos made them outrank GLSL and TypeScript, which isn't the picture
  you want. Remove them from the list to put them back.
- `--curve` compresses a dominant language. `1.0` linear, `0.4` is the default here,
  `0.3` flattens further.

### The project cards

`assets/projects.json` drives them. Two local extensions to `scripts/cards.py`
beyond the upstream version:

- **`"repo": "owner/name"`** fetches a repo directly, so **Sanchay** — which lives at
  `darved2305/Sanchay` and you contribute to rather than own — still gets a card with
  live star and fork counts.
- **`"name"`** renames the card, which is how **Medtech-Wellora** displays as
  **Wellora**.

`description` overrides the repo's own GitHub description. None of your four repos
have one set on GitHub — worth setting them there too, since it helps anyone browsing
your repo list, and then you can delete the overrides here.

Regenerate locally with:

```bash
python3 scripts/cards.py --user lakshitasethia --projects assets/projects.json --out assets
```

The contribution and streak tiles need `$GITHUB_TOKEN` set (they come from the GraphQL
API). Without one you get three tiles instead of six.

---

## If something looks broken

**Images don't load on the profile.** The repo has to be public, and the `assets/…`
paths only resolve once the files are actually pushed.

**Metrics workflow fails.** Almost always `METRICS_TOKEN`: missing, expired, or created
as a fine-grained token instead of a classic one.

**Snake images 404.** The Snake workflow hasn't completed, or step 3 was skipped so it
couldn't create the `output` branch.

**Sanchay's card vanished.** `darved2305/Sanchay` has to stay public for the direct
fetch to work unauthenticated.

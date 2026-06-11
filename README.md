# quarto-tongakuot-cv — Quarto CV Format + Alier Reng's Resume

A reusable **Quarto custom format** (`cv-typst`) that packages the
PyStatR+ resume aesthetic — deep navy, structural blue, and gold accents —
as an installable Typst-based extension, plus Alier Reng's resume built on it.

Originally converted from a `pagedown` RMarkdown resume to Quarto + Typst;
refactored into the `quarto-tongakuot-cv` extension package (June 2026).

## Files

| File | Purpose |
|---|---|
| `_extensions/cv/` | The extension: `_extension.yml`, `typst-template.typ` (palette, helpers, layout), `typst-show.typ` (YAML → template mapping). |
| `template.qmd` | Generic starter CV for new users of the format. |
| `areng_resume.qmd` | Alier's resume — content only; all styling comes from the extension. |
| `areng_resume.typ` | Quarto-generated Typst intermediate (`keep-typ: true`); not hand-edited. |
| `_quarto.yml` | Quarto project config. |

## Using the format

```bash
# Render Alier's resume
quarto render areng_resume.qmd

# Start a new CV from the template (in a fresh directory)
quarto use template tongakuot/quarto-tongakuot-cv

# Or add the format to an existing project
quarto add tongakuot/quarto-tongakuot-cv
```

Requires Quarto 1.5+ (bundled Typst engine). To publish, push this
directory to GitHub as `tongakuot/quarto-tongakuot-cv` — `quarto use
template` and `quarto add` work directly against the repo.

## Adopting this template

The only prerequisite is **Quarto 1.5+** — Typst ships inside Quarto, so
there is no LaTeX and nothing else to install.

**New CV from scratch:**

1. Run `quarto use template tongakuot/quarto-tongakuot-cv` and name the
   directory when prompted. Quarto scaffolds it with a starter `.qmd`
   (renamed to match the directory) and the `_extensions/cv/` format.
2. Replace the placeholder YAML — `name`, `headline`, `tagline`, `email`,
   `location`, `linkedin`, `github` (see *YAML options* below).
3. Fill in the body using the helpers — `entry()` for roles, `edu()` for
   degrees, `award()` for honors, `pub-entry()` for publications (see
   *Helpers available in the body*).
4. Flip the toggles for sections that don't apply, e.g.
   `#let include-publications = false` (see *Section toggles*).
5. `quarto render your-cv.qmd` — the PDF lands in `_output/`.

**Existing project:** run `quarto add tongakuot/quarto-tongakuot-cv`, then
set `format: cv-typst` in the document YAML.

**Pinning a version:** install against a tagged release for reproducible
setups — `quarto add tongakuot/quarto-tongakuot-cv@v1.0.0`. (Maintainer:
`git tag v1.0.0 && git push --tags`.)

The design lives entirely in `_extensions/cv/`; documents carry content
only. Update the format later with `quarto update tongakuot/quarto-tongakuot-cv`.

## Section toggles

The body of each document begins with toggles you can flip:

```typst
#let include-publications = true   // false ⇒ Research & Publications is omitted
```

The **Research & Publications** section ships as a placeholder built on the
`pub-entry(title, authors, venue, year, note: ...)` helper — turn it off in
one keystroke if it doesn't apply.

## YAML options

| Key | Effect |
|---|---|
| `name` | Name in the header band (rendered uppercase) and page footer. |
| `headline` | Gold all-caps line under the name. |
| `tagline` | Light one-liner under the headline. |
| `email`, `location`, `linkedin`, `github`, `website` | Right-hand contact block; links generated automatically. All optional. |
| `summary` | Optional plain-markdown summary. For styled emphasis, use `#summary-block[...]` in the body instead. |
| `resume-updated` | "Updated …" stamp in the page footer. |

## Helpers available in the body

`section-title(name)`, `sidebar-title(name)`,
`entry(role, org, place, dates, bullets)`, `edu(degree, school, place, dates)`,
`award(title, detail)`, `pub-entry(title, authors, venue, year, note: ...)`,
`summary-block(content)`, `two-col(main, sidebar)`,
plus the palette: `pystatr-navy`, `pystatr-blue`, `pystatr-steel`,
`pystatr-gold`, `pystatr-ink`, `pystatr-mute`, `pystatr-rule`, `pystatr-bg`.

## Color palette (PyStatR+)

```
navy   #0B1F3A    structural background (header band)
blue   #1E3A5F    structural accents and emphasis
steel  #3E5C82    sidebar dividers
gold   #C9A961    accent rules, bullets, highlights
ink    #0A0E1A    body text
mute   #5A6378    secondary text, locations, dates
rule   #D5DBE3    hairline rules
bg     #FAFBFC    page background
```

## Updating the resume

1. Edit `areng_resume.qmd` (content) or the extension files (design).
2. `quarto render areng_resume.qmd`
3. Collect the rendered PDF from `_output/` and submit.

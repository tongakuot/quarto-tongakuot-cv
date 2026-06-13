// =============================================================================
//  quarto-tongakuot-cv — Quarto/Typst template
//  Deep navy, structural blue, and gold accents (PyStatR+ aesthetic).
//
//  Exposed to documents using this format:
//    Colors:   pystatr-navy, pystatr-blue, pystatr-steel, pystatr-gold,
//              pystatr-ink, pystatr-mute, pystatr-rule, pystatr-bg
//    Helpers:  section-title(name), sidebar-title(name),
//              entry(role, org, place, dates, bullets),
//              edu(degree, school, place, dates),
//              award(title, detail),
//              pub-entry(title, authors, venue, year),
//              summary-block(content), two-col(main, sidebar)
//    Template: resume(...) — applied automatically via the format's show rule
// =============================================================================

// ----- brand palette ---------------------------------------------------------
#let pystatr-navy   = rgb("#0B1F3A")
#let pystatr-blue   = rgb("#1E3A5F")
#let pystatr-steel  = rgb("#3E5C82")
#let pystatr-gold   = rgb("#C9A961")
#let pystatr-ink    = rgb("#0A0E1A")
#let pystatr-mute   = rgb("#5A6378")
#let pystatr-rule   = rgb("#D5DBE3")
#let pystatr-bg     = rgb("#FAFBFC")
#let pystatr-gold-light  = rgb("#E8C875")
#let pystatr-light  = rgb("#E5EAF2")

// ----- helpers ---------------------------------------------------------------
#let section-title(name) = {
  v(0.35em)
  block[
    #grid(columns: (auto, 1fr), gutter: 0.6em, align: (left + horizon, left + horizon),
      text(size: 11pt, weight: "bold", fill: pystatr-navy, upper(name)),
      line(length: 100%, stroke: 0.6pt + pystatr-gold),
    )
  ]
  v(-0.1em)
}

#let sidebar-title(name) = {
  v(0.4em)
  text(size: 9.5pt, weight: "bold", fill: pystatr-gold, upper(name))
  v(-0.2em)
  line(length: 100%, stroke: 0.5pt + pystatr-steel)
  v(0.05em)
}

#let entry(role, org, place, dates, bullets) = {
  block(below: 0.75em)[
    #grid(columns: (1fr, auto), gutter: 0.4em,
      align: (left + horizon, right + horizon),
      [
        #text(size: 10.4pt, weight: "bold", fill: pystatr-navy)[#role]
        #h(0.3em)
        #text(size: 9.4pt, fill: pystatr-blue, weight: "semibold")[· #org]
      ],
      text(size: 9pt, fill: pystatr-mute, weight: "regular", style: "italic")[#dates],
    )
    #v(-0.25em)
    #text(size: 8.8pt, fill: pystatr-mute)[#place]
    #v(0.1em)
    #if bullets.len() > 0 [
      #set list(indent: 0.6em, body-indent: 0.4em, marker: text(fill: pystatr-gold)[▸])
      #for b in bullets [- #b]
    ]
  ]
}

#let edu(degree, school, place, dates) = {
  block(below: 0.45em)[
    #grid(columns: (1fr, auto), gutter: 0.4em,
      align: (left + horizon, right + horizon),
      [
        #text(size: 9.6pt, weight: "bold", fill: pystatr-navy)[#degree] \
        #text(size: 8.8pt, fill: pystatr-blue)[#school]
        #h(0.3em)
        #text(size: 8.4pt, fill: pystatr-mute)[· #place]
      ],
      text(size: 8.6pt, fill: pystatr-mute, style: "italic")[#dates],
    )
  ]
}

#let award(title, detail) = {
  block(below: 0.4em)[
    #text(size: 8.6pt, weight: "bold", fill: pystatr-navy)[#title] \
    #text(size: 8.0pt, fill: pystatr-mute)[#detail]
  ]
}

// Research publication entry. `authors` and `note` may be none.
// Use #emph or quotes in `title` per your citation style preference.
#let pub-entry(title, authors, venue, year, note: none) = {
  block(below: 0.5em)[
    #grid(columns: (1fr, auto), gutter: 0.4em,
      align: (left + horizon, right + horizon),
      text(size: 9.4pt, weight: "bold", fill: pystatr-navy)[#title],
      text(size: 8.6pt, fill: pystatr-mute, style: "italic")[#year],
    )
    #v(-0.25em)
    #if authors != none [
      #text(size: 8.6pt, fill: pystatr-ink)[#authors] \
    ]
    #text(size: 8.6pt, fill: pystatr-blue, style: "italic")[#venue]
    #if note != none [
      #h(0.3em) #text(size: 8.2pt, fill: pystatr-mute)[— #note]
    ]
  ]
}

#let summary-block(content) = {
  block(width: 100%)[
    #text(size: 9.5pt, fill: pystatr-ink)[#content]
  ]
  v(0.25em)
  line(length: 100%, stroke: 0.5pt + pystatr-rule)
  v(0.1em)
}

#let two-col(main, sidebar, ratio: 1.95fr) = grid(
  columns: (ratio, 1fr),
  gutter: 1.2em,
  main,
  sidebar,
)

// ----- personal details band (Africa / South Sudan variant) ------------------
// Renders a compact strip below the header when any Africa-specific field is set.
// All parameters are optional; the band is hidden when none are provided.
#let personal-details-band(
  dob: none,
  sex: none,
  nationality: none,
  marital-status: none,
  region: none,
  religion: none,
  id-number: none,
) = {
  let items = ()
  if dob != none          { items += (("Date of Birth", dob),) }
  if sex != none          { items += (("Sex", sex),) }
  if nationality != none  { items += (("Nationality", nationality),) }
  if marital-status != none { items += (("Marital Status", marital-status),) }
  if region != none       { items += (("Region / State", region),) }
  if religion != none     { items += (("Religion", religion),) }
  if id-number != none    { items += (("ID No.", id-number),) }

  if items.len() > 0 {
    let rendered = items.map(pair => {
      let (lbl, val) = pair
      box[#text(size: 7.6pt, weight: "bold", fill: pystatr-gold, tracking: 0.03em)[#upper(lbl)]#h(0.22em)#text(size: 8.0pt, fill: pystatr-ink)[#val]]
    }).join([#h(0.6em)#text(size: 8pt, fill: pystatr-steel)[·]#h(0.6em)])

    v(0.3em)
    block(
      fill: pystatr-light,
      inset: (x: 14pt, y: 7pt),
      radius: 2pt,
      width: 100%,
      below: 0.3em,
    )[#rendered]
    v(0.25em)
  }
}

// ----- the resume template ---------------------------------------------------
#let resume(
  name: none,
  headline: none,
  tagline: none,
  email: none,
  phone: none,
  location: none,
  linkedin: none,
  github: none,
  website: none,
  // Africa / South Sudan personal details (optional — band hidden when all none)
  dob: none,
  sex: none,
  nationality: none,
  marital-status: none,
  region: none,
  religion: none,
  id-number: none,
  summary: none,
  updated: none,
  paper: "us-letter",
  fontsize: 9.7pt,
  body-font: ("DejaVu Sans", "Helvetica", "Arial"),
  doc,
) = {
  set page(
    paper: paper,
    margin: (top: 0.5in, bottom: 0.5in, left: 0.55in, right: 0.55in),
    fill: pystatr-bg,
    footer: context [
      #set text(size: 7.5pt, fill: pystatr-mute, font: body-font)
      #grid(columns: (1fr, auto, 1fr),
        align: (left, center, right),
        [#if name != none [#name — Resume]],
        [#counter(page).display("1 / 1", both: true)],
        [#if updated != none [Updated #updated]],
      )
    ],
  )

  set text(font: body-font, size: fontsize, fill: pystatr-ink)
  set par(leading: 0.55em, justify: false)

  // ----- header band ---------------------------------------------------------
  block(
    fill: pystatr-navy,
    inset: (x: 16pt, y: 12pt),
    radius: 3pt,
    width: 100%,
  )[
    #grid(columns: (1.3fr, 1fr), gutter: 1em, align: (left + horizon, right + horizon),
      [
        #text(size: 22pt, weight: "bold", fill: white)[#upper(name)]
        #v(-0.25em)
        #if headline != none [
          #text(size: 9.2pt, fill: pystatr-gold, weight: "semibold")[#upper(headline)]
        ]
        #v(-0.15em)
        #if tagline != none [
          #text(size: 8.4pt, fill: rgb("#C7CEDA"))[#tagline]
        ]
      ],
      [
        #set text(size: 8.4pt, fill: pystatr-light)
        #align(right)[
          #if email != none [
            #text(fill: pystatr-gold-light, weight: "semibold")[#link("mailto:" + email)[#email]] \
          ]
          #if phone != none [
            #text(fill: pystatr-light)[#phone] \
          ]
          #if location != none [
            #text(fill: pystatr-light)[#location] \
          ]
          #if linkedin != none [
            #text(fill: pystatr-gold-light, weight: "semibold")[#link("https://www." + linkedin)[#linkedin]] \
          ]
          #if github != none [
            #text(fill: pystatr-gold-light, weight: "semibold")[#link("https://" + github)[#github]] \
          ]
          #if website != none [
            #text(fill: pystatr-gold-light, weight: "semibold")[#link("https://" + website)[#website]]
          ]
        ]
      ],
    )
  ]

  // ----- Africa / South Sudan personal details band (hidden when all none) ----
  personal-details-band(
    dob: dob,
    sex: sex,
    nationality: nationality,
    marital-status: marital-status,
    region: region,
    religion: religion,
    id-number: id-number,
  )

  v(0.3em)

  // ----- optional metadata-driven summary -------------------------------------
  if summary != none {
    summary-block(summary)
  }

  doc
}

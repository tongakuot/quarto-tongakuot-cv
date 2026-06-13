// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



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
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "a4",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: doc => resume(
  name: [Your Full Name],
  headline: [Your Professional Title · Field · Area of Expertise],
  tagline: [One-sentence positioning statement that appears under your headline.],
  email: "you\@example.com",
  phone: [+211 9XX XXX XXX],
  location: [Juba, South Sudan],
  linkedin: "linkedin.com/in/your-handle",
  github: "github.com/your-handle",
  dob: [1 January 1990],
  sex: [Male],
  nationality: [South Sudanese],
  marital-status: [Single],
  region: [Greater Equatoria],
  religion: [Christian],
  id-number: [SS-XXXXXXXXXX],
  updated: [June 2026],
  paper: "a4",
  doc,
)

// ─────────────────────────────────────────────────────────────────────────────
//  Section toggles — set to false to turn a section off entirely.
// ─────────────────────────────────────────────────────────────────────────────
#let include-publications = false

// ─────────────────────────────────────────────────────────────────────────────
//  PROFESSIONAL PROFILE / OBJECTIVE
//  In South Sudan and East Africa CVs this section is often called
//  "Professional Profile" or "Career Objective". Keep it concise (3–4 lines).
// ─────────────────────────────────────────────────────────────────────────────
#summary-block[
  Briefly describe your professional identity, years of experience, and
  the #text(weight: "bold", fill: pystatr-blue)[sectors or domains] you have worked in.
  Mention one or two signature strengths and the kind of impact you create.
  End with what you are seeking or what you can contribute to the hiring organization.
]

// ─────────────────────────────────────────────────────────────────────────────
//  TWO-COLUMN BODY
//  NOTE: In many South Sudan / East Africa CVs, Education comes FIRST.
//  If applying to government, NGO, or academic positions, move the Education
//  section-title block above Professional Experience in the main column.
// ─────────────────────────────────────────────────────────────────────────────
#two-col(

  // ── MAIN COLUMN ────────────────────────────────────────────────────────────
  [

    // ── Education first (recommended for SS / EA format) ─────────────────────
    #section-title[Education]

    #edu("Degree · Field of Study", "University or Institution Name", "City, Country", "2012 — 2016")
    #edu("Diploma or Certificate", "Institution Name", "City, Country", "2009 — 2011")

    // ── Professional Experience ───────────────────────────────────────────────
    #section-title[Professional Experience]

    #entry(
      "Job Title",
      "Organization / Employer",
      "City, Country",
      "2020 — Present",
      (
        [Describe your main responsibility — lead with a strong action verb and focus on outcomes.],
        [Quantify where possible: managed a team of #text(weight: "bold")[X staff], served #text(weight: "bold")[Y beneficiaries], covered #text(weight: "bold")[Z districts].],
        [Highlight any programs, tools, or systems you used or built.],
      )
    )

    #entry(
      "Earlier Job Title",
      "Organization / Employer",
      "City, Country",
      "2016 — 2020",
      (
        [Describe what you did and the difference it made.],
        [Mention relevant projects, stakeholders, or geographic coverage.],
      )
    )

    // ── Research & Publications (shown only when toggle is true) ───────────────
    #if include-publications [
      #section-title[Research & Publications]

      #pub-entry(
        "Title of Paper, Report, or Article",
        "Lastname, F., Co-Author, A.",
        "Journal, Publisher, or Organization",
        "2024",
      )
    ]

    // ── Volunteer & Community Work ─────────────────────────────────────────────
    #section-title[Volunteer & Community Work]

    #entry(
      "Role or Contribution",
      "Organization or Initiative",
      "City, Country",
      "2022 — Present",
      (
        [Describe community, mentorship, or civic contributions.],
      )
    )
  ],

  // ── SIDEBAR ────────────────────────────────────────────────────────────────
  [

    // ── Key Skills ────────────────────────────────────────────────────────────
    #sidebar-title[Key Skills]

    #v(0.1em)
    #set list(indent: 0pt, body-indent: 0.35em, marker: text(fill: pystatr-gold)[▪])
    - #text(size: 8.5pt)[Skill area one]
    - #text(size: 8.5pt)[Skill area two]
    - #text(size: 8.5pt)[Skill area three]
    - #text(size: 8.5pt)[Skill area four]

    // ── Languages ─────────────────────────────────────────────────────────────
    // Languages are a PROMINENT section in South Sudan / East Africa CVs.
    // List spoken and written proficiency levels clearly.
    #sidebar-title[Languages]

    #v(0.1em)
    - #text(size: 8.5pt)[English — Fluent (written & spoken)]
    - #text(size: 8.5pt)[Arabic — Conversational]
    - #text(size: 8.5pt)[Dinka / Nuer / Bari — Mother tongue]
    - #text(size: 8.5pt)[Swahili — Basic]

    // ── Tools & Technology ────────────────────────────────────────────────────
    #sidebar-title[Tools & Technology]

    #v(0.1em)
    - #text(size: 8.5pt)[Microsoft Office Suite]
    - #text(size: 8.5pt)[Data tool · Reporting tool]
    - #text(size: 8.5pt)[Other relevant software]

    // ── Certifications & Training ─────────────────────────────────────────────
    #sidebar-title[Certifications]

    #v(0.1em)
    - #text(size: 8.5pt)[Certificate Name — Issuing Body, Year]
    - #text(size: 8.5pt)[Training Program — Organization, Year]

    // ── Awards & Recognition ──────────────────────────────────────────────────
    #sidebar-title[Awards]

    #award("Award Name · Year", "Issuing organization — one-line context")

    // ── References ────────────────────────────────────────────────────────────
    // References are typically included (or "available on request") in
    // South Sudan / East Africa CVs. List 2–3 professional referees.
    #sidebar-title[References]

    #v(0.1em)
    #set text(size: 8.0pt, fill: pystatr-ink)
    #text(weight: "bold")[Referee Name] \
    #text(fill: pystatr-mute)[Title, Organization] \
    #text(fill: pystatr-mute)[Phone: +XXX XXX XXX XXX] \
    #text(fill: pystatr-mute)[Email: referee@org.com]

    #v(0.4em)
    #text(weight: "bold")[Second Referee Name] \
    #text(fill: pystatr-mute)[Title, Organization] \
    #text(fill: pystatr-mute)[Phone: +XXX XXX XXX XXX] \
    #text(fill: pystatr-mute)[Email: referee2@org.com]
  ],
)




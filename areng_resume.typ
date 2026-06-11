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

// ----- the resume template ---------------------------------------------------
#let resume(
  name: none,
  headline: none,
  tagline: none,
  email: none,
  location: none,
  linkedin: none,
  github: none,
  website: none,
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

  v(0.45em)

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
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: doc => resume(
  name: [Alier Reng],
  headline: [Healthcare Quality · Safety · Compliance Leader],
  tagline: [Data-driven director with 9+ years across CMS quality programs, NHSN safety reporting, and clinical operations analytics.],
  email: "alierwai254\@gmail.com",
  location: [Louisville, KY · open to relocation],
  linkedin: "linkedin.com/in/tongakuot",
  github: "github.com/tongakuot",
  updated: [June 2026],
  paper: "us-letter",
  doc,
)

// Toggle: set to true to include the Research & Publications section.
#let include-publications = false

// ============================================================================
//  SUMMARY
// ============================================================================
#summary-block[
  Healthcare quality and analytics leader with #text(weight: "bold", fill: pystatr-blue)[9+ years] partnering with Clinical Operations, Quality, and Care Management leaders to operationalize #text(weight: "bold", fill: pystatr-blue)[CMS quality programs] (VBP, HAC Reduction, MSPB), #text(weight: "bold", fill: pystatr-blue)[NHSN safety reporting], and the #text(weight: "bold", fill: pystatr-blue)[National Quality Strategy (NQS)] across multi-hospital systems. Recognized for rigorous data stewardship and translating complex measure specifications into actionable scorecards that improve quality and patient safety. LifePoint Health #text(weight: "bold", fill: pystatr-gold)[Mercy Award] recipient (2020).
]

// ============================================================================
//  TWO-COLUMN BODY
// ============================================================================
#two-col(
  // --- MAIN ---
  [
    #section-title[Professional Experience]

    #entry(
      "Regional Director, Quality & Safety Operations",
      "LifePoint Health",
      "Brentwood, TN · Remote",
      "Jun 2026 — Present",
      (
        [Serve as #text(weight: "bold")[data architect] for inpatient acute care hospitals — designing the data structures, validation protocols, and pipelines behind quality analytics.],
      )
    )

    #entry(
      "Director, Analytics & Quality Reporting",
      "ScionHealth",
      "Louisville, KY",
      "2022 — 2026",
      (
        [Lead data stewardship for quality and operational reporting across the #text(weight: "bold")[Community Hospitals Division] — designing initial and monthly data-validation protocols that protect the integrity of quality and safety metrics.],
        [Partner with SMEs and Clinical Operations leaders to develop, document, and operationalize #text(weight: "bold")[National Quality Strategy (NQS)] measures — including specifications, calculation logic, and audit trails.],
        [Author #text(weight: "bold")[Quality Measures Specifications] and field-level reporting instructions used by hospital quality and compliance leaders.],
        [Compile and compress monthly #text(weight: "bold")[NQS Excel workbooks for 75+ hospitals enterprise-wide] with R and openpyxl — cutting production time from #text(weight: "bold", fill: pystatr-gold)[several days to \~4 hours] while improving accuracy and consistency.],
        [Automate divisional Excel reporting with #text(weight: "bold")[Python (openpyxl)] — the #text(weight: "bold")[Apogee and TeamHealth GMLOS Variance] reports and the #text(weight: "bold")[Quality & Regulatory Outcomes HCAHPS and ED CAHPS trend] reports — strengthening accuracy and audit-readiness across patient-experience, safety, and utilization metrics.],
        [Build #text(weight: "bold")[R Shiny] applications for monthly Operating Review (MOR) data — giving executive and frontline leaders interactive access to quality, safety, and throughput indicators.],
      )
    )

    #entry(
      "Senior Data Analyst, Quality Data",
      "LifePoint Health",
      "Brentwood, TN",
      "2021 — 2022",
      (
        [Data stewardship: performed monthly data validation to ensure data accuracy before data was pushed to PowerBI for hospitals' use.],
        [Supported and assisted hospitals and the HSC departments with their data needs.],
        [Performed exploratory and predictive analysis with R and Python.],
        [Created and modified divisions' and hospitals' #text(weight: "bold")[NHSN Goals, MOR, and QOC] reports and dashboards using R and PowerBI.],
        [Onboarded and trained new team members.],
      )
    )

    #entry(
      "Data Analyst, Quality Data",
      "LifePoint Health",
      "Brentwood, TN",
      "2016 — 2021",
      (
        [Cut #text(weight: "bold")[QOC and MOR] decks production time by #text(weight: "bold", fill: pystatr-gold)[80%] by automating reports with R Shiny.],
        [Reduced data errors and optimized accuracy by automating #text(weight: "bold")[CHOIS monthly mortality] reports with R Shiny.],
        [Used R to automate the CMS company-wide #text(weight: "bold")[VBP, HAC Penalty, and MSPB] reports extraction processes.],
      )
    )

    #section-title[Teaching & Public Education]

    #entry(
      "Lecturer, Mathematics",
      "Middle Tennessee State University",
      "Murfreesboro, TN",
      "2011 — 2016",
      (
        [Taught general mathematics courses — Plane Trigonometry, Applied Calculus I, Applied Statistics, Finite Mathematics, College Algebra, Mathematics for General Studies (Mathematical Ideas), and Pre-Calculus (Pathways to Calculus).],
        [Turned 'F' students into 'A' and 'B' students through active and participatory learning; used hands-on approaches to help students conceptualize mathematical ideas and construct meaningful mathematical statements.],
        [Helped challenged students replace negative thinking with positive-possibility mindsets through friendly coaching and mentorship.],
      )
    )

    #if include-publications [
      #section-title[Research & Publications]

      #pub-entry(
        "Publication Title Goes Here",
        "Reng, A., Co-Author, B.",
        "Journal or Venue Name",
        "2026",
      )
    ]

    #section-title[Leadership & Community]

    #entry(
      "Founder & Lead Educator",
      "PyStatR+ — mission-driven data science education",
      "Louisville, KY",
      "2024 — Present",
      (
        [Founded the first South Sudanese-American, U.S.-based data science education initiative — delivering accessible education in data science, statistics, ML, and AI with a focused commitment to learners in South Sudan and East Africa.],
        [Author open tutorials in R, Python, and statistics; publish across the PyStatR+ YouTube channel, Facebook community, Medium, and blog with reproducible Quarto notebooks.],
        [Design and deliver group training programs (1-day, 5-day, 8-week) for students, professionals, NGOs, and government agencies — sharpening curriculum design, reproducibility, and technical communication skills.],
      )
    )
  ],

  // --- SIDEBAR ---
  [
    #sidebar-title[Quality & Compliance]

    #v(0.1em)
    #set list(indent: 0pt, body-indent: 0.35em, marker: text(fill: pystatr-gold)[▪])
    - #text(size: 8.5pt)[CMS VBP · HAC Reduction · MSPB]
    - #text(size: 8.5pt)[HCAHPS & ED CAHPS trend reporting]
    - #text(size: 8.5pt)[NHSN safety & infection reporting]
    - #text(size: 8.5pt)[National Quality Strategy (NQS)]
    - #text(size: 8.5pt)[Quality Measures Specifications]
    - #text(size: 8.5pt)[QOC, MOR, GMLOS variance]
    - #text(size: 8.5pt)[Mortality (CHOIS) reporting]
    - #text(size: 8.5pt)[Data stewardship & validation]
    - #text(size: 8.5pt)[Audit-readiness & documentation]

    #sidebar-title[Analytics & Tools]

    #v(0.1em)
    - #text(size: 8.5pt)[R · Python · SQL]
    - #text(size: 8.5pt)[R Shiny · Shiny for Python]
    - #text(size: 8.5pt)[openpyxl · Quarto · tidymodels]
    - #text(size: 8.5pt)[PowerBI dashboards & DAX]
    - #text(size: 8.5pt)[pandas · Polars · scikit-learn]
    - #text(size: 8.5pt)[Positron · RStudio · VS Code]
    - #text(size: 8.5pt)[JupyterLab · Git / GitHub · MS Office]

    #sidebar-title[Leadership Strengths]

    #v(0.1em)
    - #text(size: 8.5pt)[Cross-functional partnership with Clinical Ops & Care Management]
    - #text(size: 8.5pt)[Translating regulatory measures into operational dashboards]
    - #text(size: 8.5pt)[Coaching, mentorship, and team development]
    - #text(size: 8.5pt)[Executive-ready written communication]

    #sidebar-title[Education]

    #edu("MBA · Information Systems Management", "LeTourneau University", "Longview, TX", "2016 — 2017")
    #edu("M.S. · Professional Science (Biostatistics)", "Middle Tennessee State University", "Murfreesboro, TN", "2009 — 2011")
    #edu("B.S. · Neuroscience", "University of Texas at Dallas", "Richardson, TX", "2005 — 2008")

    #v(0.6em)

    #sidebar-title[Awards]

    #award("Mercy Award · 2020", "LifePoint Health — quality mission contribution")
    #award("LSAMP Scholarship · 2006–2007", "The University of Texas at Dallas")
    #award("Vice President's List · 2005", "Richland College (DCCCD)")
  ],
)




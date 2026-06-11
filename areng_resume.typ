// =============================================================================
//  Alier Reng — Resume
//  Targeted: Regional Director, Quality & Safety Compliance
//  PyStatR+ aesthetic: deep navy, metallic blue, gold accents.
//  Engine: Typst 0.13+
// =============================================================================

#let pystatr-navy   = rgb("#0B1F3A")   // deep metallic navy
#let pystatr-blue   = rgb("#1E3A5F")   // structural blue
#let pystatr-steel  = rgb("#3E5C82")   // muted steel
#let pystatr-gold   = rgb("#C9A961")   // PyStatR+ gold
#let pystatr-ink    = rgb("#0A0E1A")   // near-black body ink
#let pystatr-mute   = rgb("#5A6378")   // muted text
#let pystatr-rule   = rgb("#D5DBE3")   // hairline rule
#let pystatr-bg     = rgb("#FAFBFC")   // off-white background

#set page(
  paper: "us-letter",
  margin: (top: 0.5in, bottom: 0.5in, left: 0.55in, right: 0.55in),
  fill: pystatr-bg,
  footer: context [
    #set text(size: 7.5pt, fill: pystatr-mute, font: "DejaVu Sans")
    #grid(columns: (1fr, auto, 1fr),
      align: (left, center, right),
      [Alier Reng — Resume],
      [#counter(page).display("1 / 1", both: true)],
      [Updated April 2026],
    )
  ],
)

#set text(font: ("DejaVu Sans", "Helvetica", "Arial"), size: 9.7pt, fill: pystatr-ink)
#set par(leading: 0.55em, justify: false)
// no global show-rule for link — we color links contextually so they remain
// visible against both the light body and the dark navy header band.
#let bodylink(url, label) = text(fill: pystatr-blue, weight: "regular")[#link(url)[#label]]

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

// ============================================================================
//  HEADER — name + targeted headline + contact
// ============================================================================
#block(
  fill: pystatr-navy,
  inset: (x: 16pt, y: 12pt),
  radius: 3pt,
  width: 100%,
)[
  #grid(columns: (1.3fr, 1fr), gutter: 1em, align: (left + horizon, right + horizon),
    [
      #text(size: 22pt, weight: "bold", fill: white)[ALIER RENG]
      #v(-0.25em)
      #text(size: 9.2pt, fill: pystatr-gold, weight: "semibold")[
        HEALTHCARE QUALITY  ·  SAFETY  ·  COMPLIANCE LEADER
      ]
      #v(-0.15em)
      #text(size: 8.4pt, fill: rgb("#C7CEDA"))[
        Data-driven director with 9+ years across CMS quality programs, NHSN safety reporting, and clinical operations analytics.
      ]
    ],
    [
      #let hcolor = rgb("#E8C875")
      #let hlight = rgb("#E5EAF2")
      #set text(size: 8.4pt, fill: hlight)
      #align(right)[
        #text(fill: hcolor, weight: "semibold")[#link("mailto:alierwai254@gmail.com")[alierwai254\@gmail.com]] \
        #text(fill: hlight)[Louisville, KY  ·  open to relocation] \
        #text(fill: hcolor, weight: "semibold")[#link("https://www.linkedin.com/in/tongakuot/")[linkedin.com/in/tongakuot]] \
        #text(fill: hcolor, weight: "semibold")[#link("http://github.com/tongakuot")[github.com/tongakuot]]
      ]
    ],
  )
]

#v(0.45em)

// ============================================================================
//  SUMMARY — tailored to Quality & Safety Compliance Director
// ============================================================================
#block(width: 100%)[
  #text(size: 9.5pt, fill: pystatr-ink)[
    Healthcare quality and analytics leader with #text(weight: "bold", fill: pystatr-blue)[9+ years] partnering with Clinical Operations, Quality, and Care Management leaders to operationalize #text(weight: "bold", fill: pystatr-blue)[CMS quality programs] (VBP, HAC Reduction, MSPB), #text(weight: "bold", fill: pystatr-blue)[NHSN safety reporting], and the #text(weight: "bold", fill: pystatr-blue)[National Quality Strategy (NQS)] across multi-hospital systems. Recognized for rigorous data stewardship and translating complex measure specifications into actionable scorecards that improve quality and patient safety. LifePoint Health #text(weight: "bold", fill: pystatr-gold)[Mercy Award] recipient (2020).
  ]
]

#v(0.25em)
#line(length: 100%, stroke: 0.5pt + pystatr-rule)
#v(0.1em)

// ============================================================================
//  TWO-COLUMN BODY
// ============================================================================
#grid(
  columns: (1.95fr, 1fr),
  gutter: 1.2em,

  // --------------------------------------------------------------- MAIN -----
  [
    #section-title[Professional Experience]

    #entry(
      "Director, Analytics & Quality Reporting",
      "ScionHealth",
      "Louisville, KY",
      "2022 — Present",
      (
        [Lead data stewardship for quality and operational reporting across the #text(weight: "bold")[Community Hospitals Division] — designing initial and monthly data-validation protocols that protect the integrity of quality and safety metrics.],
        [Partner with SMEs and Clinical Operations leaders to develop, document, and operationalize #text(weight: "bold")[National Quality Strategy (NQS)] measures — including specifications, calculation logic, and audit trails.],
        [Author #text(weight: "bold")[Quality Measures Specifications] and field-level reporting instructions used by hospital quality and compliance leaders.],
        [Compile and compress monthly #text(weight: "bold")[NQS Excel workbooks for 75+ hospitals enterprise-wide] with R and openpyxl — cutting production time from #text(weight: "bold", fill: pystatr-gold)[several days to ~4 hours] while improving accuracy and consistency.],
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

  // ------------------------------------------------------------ SIDEBAR -----
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

    #block(below: 0.4em)[
      #text(size: 8.6pt, weight: "bold", fill: pystatr-navy)[Mercy Award · 2020] \
      #text(size: 8.0pt, fill: pystatr-mute)[LifePoint Health — quality mission contribution]
    ]
    #block(below: 0.4em)[
      #text(size: 8.6pt, weight: "bold", fill: pystatr-navy)[LSAMP Scholarship · 2006–2007] \
      #text(size: 8.0pt, fill: pystatr-mute)[The University of Texas at Dallas]
    ]
    #block(below: 0.4em)[
      #text(size: 8.6pt, weight: "bold", fill: pystatr-navy)[Vice President's List · 2005] \
      #text(size: 8.0pt, fill: pystatr-mute)[Richland College (DCCCD)]
    ]
  ],
)

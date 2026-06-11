#show: doc => resume(
$if(name)$
  name: [$name$],
$endif$
$if(headline)$
  headline: [$headline$],
$endif$
$if(tagline)$
  tagline: [$tagline$],
$endif$
$if(email)$
  email: "$email$",
$endif$
$if(location)$
  location: [$location$],
$endif$
$if(linkedin)$
  linkedin: "$linkedin$",
$endif$
$if(github)$
  github: "$github$",
$endif$
$if(website)$
  website: "$website$",
$endif$
$if(summary)$
  summary: [$summary$],
$endif$
$if(resume-updated)$
  updated: [$resume-updated$],
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
  doc,
)

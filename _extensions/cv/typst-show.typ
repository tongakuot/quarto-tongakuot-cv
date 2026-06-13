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
$if(phone)$
  phone: [$phone$],
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
$if(dob)$
  dob: [$dob$],
$endif$
$if(sex)$
  sex: [$sex$],
$endif$
$if(nationality)$
  nationality: [$nationality$],
$endif$
$if(marital-status)$
  marital-status: [$marital-status$],
$endif$
$if(region)$
  region: [$region$],
$endif$
$if(religion)$
  religion: [$religion$],
$endif$
$if(id-number)$
  id-number: [$id-number$],
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

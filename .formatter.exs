locals_without_parens = [
  a: :*,
  abbr: :*,
  action: :*,
  address: :*,
  area: :*,
  article: :*,
  aside: :*,
  attribute: :*,
  audio: :*,
  authorization: :*,
  b: :*,
  base: :*,
  bdi: :*,
  bdo: :*,
  belongs_to: :*,
  bindings: :*,
  blockquote: :*,
  body: :*,
  br: :*,
  button: :*,
  canvas: :*,
  caption: :*,
  cite: :*,
  code: :*,
  col: :*,
  colgroup: :*,
  context: :*,
  data: :*,
  datalist: :*,
  dd: :*,
  del: :*,
  details: :*,
  dfn: :*,
  dialog: :*,
  div: :*,
  dl: :*,
  dt: :*,
  each: :*,
  em: :*,
  embed: :*,
  fieldset: :*,
  figcaption: :*,
  figure: :*,
  footer: :*,
  form: :*,
  h1: :*,
  h2: :*,
  h3: :*,
  h4: :*,
  h5: :*,
  h6: :*,
  has_many: :*,
  head: :*,
  header: :*,
  hr: :*,
  html: :*,
  i: :*,
  iframe: :*,
  img: :*,
  input: :*,
  ins: :*,
  kbd: :*,
  key: :*,
  label: :*,
  legend: :*,
  li: :*,
  link: :*,
  main: :*,
  map: :*,
  mark: :*,
  markdown: :*,
  meta: :*,
  meter: :*,
  model: :*,
  model: :*,
  nav: :*,
  noscript: :*,
  object: :*,
  ol: :*,
  optgroup: :*,
  option: :*,
  output: :*,
  p: :*,
  param: :*,
  picture: :*,
  pre: :*,
  primary_key: :*,
  progress: :*,
  q: :*,
  render: :*,
  rp: :*,
  rt: :*,
  ruby: :*,
  s: :*,
  samp: :*,
  script: :*,
  section: :*,
  select: :*,
  slot: :*,
  small: :*,
  source: :*,
  span: :*,
  strong: :*,
  style: :*,
  sub: :*,
  summary: :*,
  sup: :*,
  svg: :*,
  table: :*,
  tbody: :*,
  td: :*,
  template: :*,
  textarea: :*,
  tfoot: :*,
  th: :*,
  thead: :*,
  time: :*,
  title: :*,
  tr: :*,
  track: :*,
  u: :*,
  ui: :*,
  ul: :*,
  var: :*,
  video: :*,
  view: :*,
  view: :*,
  wbr: :*,
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  import_deps: [:ecto, :ecto_sql, :plug, :diesel],
  export: [
    locals_without_parens: locals_without_parens
  ]
]

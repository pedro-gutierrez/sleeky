locals_without_parens = [
  a: :*,
  abbr: :*,
  action: :*,
  address: :*,
  all: :*,
  all: :*,
  area: :*,
  article: :*,
  aside: :*,
  attribute: :*,
  audio: :*,
  authorization: :*,
  authorization: :*,
  authorization: :*,
  b: :*,
  base: :*,
  bdi: :*,
  bdo: :*,
  belongs_to: :*,
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
  context: :*,
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
  endpoint: :*,
  eq: :*,
  expand: :*,
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
  is_false: :*,
  is_true: :*,
  json_api: :*,
  kbd: :*,
  key: :*,
  label: :*,
  legend: :*,
  li: :*,
  link: :*,
  main: :*,
  map: :*,
  mark: :*,
  member: :*,
  meta: :*,
  meter: :*,
  model: :*,
  model: :*,
  model: :*,
  mount: :*,
  nav: :*,
  noscript: :*,
  not_nil: :*,
  object: :*,
  ol: :*,
  one: :*,
  one: :*,
  optgroup: :*,
  option: :*,
  output: :*,
  p: :*,
  page: :*,
  param: :*,
  path: :*,
  picture: :*,
  plugs: :*,
  pre: :*,
  primary_key: :*,
  progress: :*,
  q: :*,
  role: :*,
  roles: :*,
  rp: :*,
  rt: :*,
  ruby: :*,
  s: :*,
  same: :*,
  samp: :*,
  scope: :*,
  scope: :*,
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
  task: :*,
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
  unique: :*,
  using: :*,
  var: :*,
  video: :*,
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

locals_without_parens = [
  action: :*,
  all: :*,
  allow: :*,
  attribute: :*,
  authorization: :*,
  authorization: :*,
  authorization: :*,
  belongs_to: :*,
  context: :*,
  context: :*,
  context: :*,
  endpoint: :*,
  eq: :*,
  has_many: :*,
  json_api: :*,
  key: :*,
  model: :*,
  model: :*,
  model: :*,
  mount: :*,
  not_nil: :*,
  one: :*,
  path: :*,
  plugs: :*,
  primary_key: :*,
  roles: :*,
  scope: :*,
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  import_deps: [:ecto, :ecto_sql, :plug, :diesel],
  export: [
    locals_without_parens: locals_without_parens
  ]
]

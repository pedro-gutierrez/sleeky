locals_without_parens = [
  action: :*,
  all: :*,
  allow: :*,
  attribute: :*,
  authorization: :*,
  authorization: :*,
  belongs_to: :*,
  context: :*,
  eq: :*,
  has_many: :*,
  key: :*,
  model: :*,
  model: :*,
  not_nil: :*,
  one: :*,
  path: :*,
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

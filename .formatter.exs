[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: Sleeky.Dsl.locals_without_parens(),
  export: [
    locals_without_parens: Sleeky.Dsl.locals_without_parens()
  ]
]

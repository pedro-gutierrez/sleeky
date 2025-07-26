import Config

config :logger,
  level: :warning

config :logger, :console, metadata: [:reason]

config :sleeky, :ecto_repos, [Blogs.Repo]

config :sleeky, Blogs.Repo,
  url: "postgres://localhost/blogs_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test"

config :sleeky, Sleeky,
  repo: Blogs.Repo,
  endpoint: Blogs.Endpoint,
  app: Blogs.App

config :sleeky, Blogs.Endpoint, port: 80

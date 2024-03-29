import Config

config :logger, level: :warning

config :sleeky, :ecto_repos, [Blogs.Repo]

config :sleeky, Blogs.Repo,
  url: "postgres://localhost/blogs_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test"

config :sleeky, Sleeky,
  repo: Blogs.Repo,
  contexts: [
    Blogs.Publishing,
    Blogs.Notifications,
    Blogs.Accounts
  ]

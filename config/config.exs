import Config

config :sleeky, ecto_repos: [Blog.Repo]

config :sleeky, Blog.Repo,
  database: "blog",
  username: "pedrogutierrez"

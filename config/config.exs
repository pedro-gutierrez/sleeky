import Config

config :bee, ecto_repos: [Blog.Repo]

config :bee, Blog.Repo,
  database: "blog",
  username: "pedrogutierrez"

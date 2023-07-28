import Config

config :sleeki, ecto_repos: [Blog.Repo]

config :sleeki, Blog.Repo,
  database: "blog",
  username: "pedrogutierrez"

import Config

config :blog, ecto_repos: [Blog.Repo]
config :tesla, adapter: Tesla.Adapter.Hackney

if config_env() == :test do
  config :logger, level: :warn

  config :blog, Blog.Repo,
    database: "blog_test",
    username: "blog",
    password: "blog",
    pool: Ecto.Adapters.SQL.Sandbox
end

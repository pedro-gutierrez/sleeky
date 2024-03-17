import Config

config :sleeky, Sleeky,
  repo: Blogs.Repo,
  contexts: [
    Blogs.Publishing,
    Blogs.Notifications,
    Blogs.Accounts
  ]

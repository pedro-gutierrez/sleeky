# Add Sleeky to an existing Phoenix project

The `sleeky.new` installer generates a simple plug based project from scratch. However, if you already have a Phoenix project, it is quite straightforward to add Sleeky into it.

## Add sleeky to your mix dependencies

```elixir
def deps do
  [{:sleeky, "~> 0.4"}]
end
```

## Define a feature, and a model

At the very least, create both a feature and a model:

```elixir
# lib/my_app/accounts.ex
defmodule MyApp.Accounts do
  use Sleeky.Feature

  feature do
    models do
      MyApp.Accounts.User
    end
  end
end
```

```elixir
# lib/my_app/accounts/user.ex
defmodule MyApp.Accounts.User do
  use Sleeky.Model

  model do
    attribute :email, kind: :string
  end
end
```

## Configure sleeky

In your `config.exs`, let Sleeky know about your repo and your features:

```elixir
config :sleeky, Sleeky,
  repo: MyApp.Repo,
  features: [
    MyApp.Accounts
  ]
```

## Migrate your database

Generate migrations for your features and models with:

```bash
$ mix sleeky.gen.migrations
```

then migrate your database as usual with `mix ecto.migrate`.

defmodule Sleeky.Repo do
  @moduledoc """
  Sets up your repo with some defaults and pagination
  """

  defmacro __using__(opts) do
    opts = Keyword.put_new(opts, :adapter, Ecto.Adapters.Postgres)

    quote do
      use Ecto.Repo, unquote(opts)
      use Paginator
    end
  end
end

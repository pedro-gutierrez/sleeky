defmodule Blog.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Blog.Repo,
      Blog.Port
    ]

    opts = [strategy: :one_for_one, name: Blog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

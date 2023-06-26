defmodule Blog.Port do
  @moduledoc false

  def child_spec(_) do
    Supervisor.child_spec(
      {Bandit,
       [
         plug: Blog.Router,
         scheme: :http,
         options: [port: System.get_env("PORT", "4001") |> String.to_integer()]
       ]},
      []
    )
  end
end

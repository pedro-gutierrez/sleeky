defmodule Sleeky.App.Generator.Roles do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(app, _opts) do
    quote do
      def roles_from_context(context) do
        unquote(app.roles)
        |> Enum.reduce(context, fn key, acc ->
          if acc, do: Map.get(acc, key)
        end)
        |> then(fn
          nil -> {:error, :no_such_roles_path}
          roles when is_list(roles) -> {:ok, roles}
        end)
      end
    end
  end
end

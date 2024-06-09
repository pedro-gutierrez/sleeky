defmodule Sleeky.Context.Generator.Roles do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(context, _), do: roles_fun(context.authorization, context)

  defp roles_fun(nil, _) do
    quote do
      def roles(_params), do: []
    end
  end

  defp roles_fun(auth, _) do
    quote do
      def roles(params) do
        Enum.reduce(unquote(auth.roles()), params, fn key, acc ->
          if acc, do: Map.get(acc, key)
        end)
      end
    end
  end
end

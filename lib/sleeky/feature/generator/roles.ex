defmodule Sleeky.Feature.Generator.Roles do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _), do: roles_fun(feature.scopes, feature)

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

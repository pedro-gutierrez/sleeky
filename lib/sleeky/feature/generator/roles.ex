defmodule Sleeky.Feature.Generator.Roles do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _), do: roles_fun(feature.scopes, feature)

  defp roles_fun([], _) do
    quote do
      def roles(_params), do: []
    end
  end

  defp roles_fun(_, _) do
    quote do
      def roles(_context) do
        []
      end
    end
  end
end

defmodule Sleeky.Scopes.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(scopes, _) do
    quote do
      def roles, do: unquote(scopes.roles)
      def scopes, do: unquote(Macro.escape(scopes.scopes))
    end
  end
end

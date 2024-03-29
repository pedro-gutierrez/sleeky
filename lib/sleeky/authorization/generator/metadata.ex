defmodule Sleeky.Authorization.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, auth) do
    quote do
      def roles, do: unquote(auth.roles)
      def scopes, do: unquote(Macro.escape(auth.scopes))
    end
  end
end

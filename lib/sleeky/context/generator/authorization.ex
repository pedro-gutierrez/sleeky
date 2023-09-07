defmodule Sleeky.Context.Generator.Authorization do
  @moduledoc """
  Generates authorization code for a context
  """
  @behaviour Diesel.Generator

  @impl true
  def generate(_mod, definition), do: [authorize_function(definition.authorization)]

  defp authorize_function(nil) do
    quote do
      def authorize(_entity, _action, _context), do: :ok
    end
  end

  defp authorize_function(auth_module) do
    quote do
      def authorize(entity, action, context) do
        unquote(auth_module).authorize(entity, action, context)
      end
    end
  end
end

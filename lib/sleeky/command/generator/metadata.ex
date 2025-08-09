defmodule Sleeky.Command.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(command, _opts) do
    quote do
      def atomic?, do: unquote(command.atomic?)
      def params, do: unquote(command.params)
      def feature, do: unquote(command.feature)
      def policies, do: unquote(Macro.escape(command.policies))
    end
  end
end

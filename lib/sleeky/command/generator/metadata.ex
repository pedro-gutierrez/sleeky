defmodule Sleeky.Command.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(command, _opts) do
    quote do
      def fun_name, do: unquote(command.fun_name)
      def atomic?, do: unquote(command.atomic?)
      def params, do: unquote(command.params)
      def returns, do: unquote(command.returns)
      def feature, do: unquote(command.feature)
      def policies, do: unquote(Macro.escape(command.policies))
      def handler, do: unquote(command.handler)
      def events, do: unquote(Macro.escape(command.events))
    end
  end
end

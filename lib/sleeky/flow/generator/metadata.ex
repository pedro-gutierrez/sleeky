defmodule Sleeky.Flow.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(flow, _opts) do
    quote do
      def feature, do: unquote(flow.feature)
      def fun_name, do: unquote(flow.fun_name)
      def create_model_fun_name, do: unquote(flow.create_model_fun_name)
      def model, do: unquote(flow.model)
      def params, do: unquote(flow.params)
      def event, do: unquote(flow.event)
      def steps, do: unquote(Macro.escape(flow.steps))
    end
  end
end

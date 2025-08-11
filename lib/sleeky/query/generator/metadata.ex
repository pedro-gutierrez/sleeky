defmodule Sleeky.Query.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(query, _opts) do
    quote do
      def params, do: unquote(query.params)
      def model, do: unquote(query.model)
      def feature, do: unquote(query.feature)
      def policies, do: unquote(Macro.escape(query.policies))
      def many?, do: unquote(query.many)
      def limit, do: unquote(query.limit)
      def custom?, do: unquote(query.custom)
    end
  end
end

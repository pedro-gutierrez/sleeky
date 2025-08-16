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
      def limit, do: unquote(query.limit)
      def sorting, do: unquote(Macro.escape(query.sorting))
      def custom?, do: unquote(query.custom)
      def many?, do: unquote(query.many)
      def debug?, do: unquote(query.debug)
    end
  end
end

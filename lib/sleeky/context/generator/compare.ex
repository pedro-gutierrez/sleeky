defmodule Sleeky.Context.Generator.Compare do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_schema, _definition) do
    quote do
      def compare(nil, nil, _), do: true
      def compare(nil, _, _), do: false
      def compare(v, v, :eq), do: true
      def compare(%{id: id}, %{id: id}, :eq), do: true
      def compare(id, %{id: id}, :eq), do: true
      def compare(%{id: id}, id, :eq), do: true
      def compare(v1, v2, :eq) when is_list(v1), do: Enum.any?(v1, &compare(&1, v2, :eq))
      def compare(_, _, :eq), do: false
      def compare(v1, v2, :gt), do: v1 > v2
      def compare(v1, v2, :gte), do: v1 >= v2
      def compare(v1, v2, :lt), do: v1 < v2
      def compare(v1, v2, :lte), do: v1 <= v2

      def compare(v, values, :in) when is_list(v) and is_list(values) do
        v = comparable(v)
        values = comparable(values)

        not Enum.empty?(v -- v -- values)
      end

      def compare(v, values, :in) when is_list(values) do
        v = comparable(v)
        values = comparable(values)

        Enum.member?(values, v)
      end

      def compare(v, value, :in), do: compare(v, [value], :in)

      def compare(v, values, :not_in) when is_list(v) and is_list(values) do
        v = comparable(v)
        values = comparable(values)

        Enum.empty?(v -- v -- values)
      end

      def compare(v, values, :not_in) when is_list(values) do
        v = comparable(v)
        values = comparable(values)

        !Enum.member?(values, v)
      end

      def compare(v, value, :not_in), do: compare(v, [value], :not_in)

      defp comparable(values) when is_list(values), do: Enum.map(values, &comparable/1)
      defp comparable(%{id: id}), do: %{id: id}
      defp comparable(other), do: other
    end
  end
end

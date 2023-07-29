defmodule Sleeky.Schema.Compare do
  @moduledoc false

  def ast(_schema) do
    List.flatten([
      compare_nils(),
      compare_eq(),
      compare_gt(),
      compare_lt(),
      compare_in(),
      compare_not_in(),
      comparable()
    ])
  end

  defp compare_nils do
    [
      quote do
        def compare(nil, nil, _), do: true
      end,
      quote do
        def compare(nil, _, _), do: false
      end
    ]
  end

  defp compare_eq do
    [
      quote do
        def compare(v, v, :eq), do: true
      end,
      quote do
        def compare(%{id: id}, %{id: id}, :eq), do: true
      end,
      quote do
        def compare(id, %{id: id}, :eq), do: true
      end,
      quote do
        def compare(%{id: id}, id, :eq), do: true
      end,
      quote do
        def compare(v1, v2, :eq) when is_list(v1), do: Enum.any?(v1, &compare(&1, v2, :eq))
      end,
      quote do
        def compare(_, _, :eq), do: false
      end
    ]
  end

  defp compare_gt do
    [
      quote do
        def compare(v1, v2, :gt), do: v1 > v2
      end,
      quote do
        def compare(v1, v2, :gte), do: v1 >= v2
      end
    ]
  end

  defp compare_lt do
    [
      quote do
        def compare(v1, v2, :lt), do: v1 < v2
      end,
      quote do
        def compare(v1, v2, :lte), do: v1 <= v2
      end
    ]
  end

  defp compare_in do
    [
      quote do
        def compare(v, values, :in) when is_list(v) and is_list(values) do
          v = comparable(v)
          values = comparable(values)

          not Enum.empty?(v -- v -- values)
        end
      end,
      quote do
        def compare(v, values, :in) when is_list(values) do
          v = comparable(v)
          values = comparable(values)

          Enum.member?(values, v)
        end
      end,
      quote do
        def compare(v, value, :in), do: compare(v, [value], :in)
      end
    ]
  end

  defp compare_not_in do
    [
      quote do
        def compare(v, values, :not_in) when is_list(v) and is_list(values) do
          v = comparable(v)
          values = comparable(values)

          Enum.empty?(v -- v -- values)
        end
      end,
      quote do
        def compare(v, values, :not_in) when is_list(values) do
          v = comparable(v)
          values = comparable(values)

          !Enum.member?(values, v)
        end
      end,
      quote do
        def compare(v, value, :not_in), do: compare(v, [value], :not_in)
      end
    ]
  end

  defp comparable do
    [
      quote do
        defp comparable(values) when is_list(values), do: Enum.map(values, &comparable/1)
      end,
      quote do
        defp comparable(%{id: id}), do: %{id: id}
      end,
      quote do
        defp comparable(other), do: other
      end
    ]
  end
end

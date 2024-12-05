defmodule Sleeky.Ui.View.Expand do
  @moduledoc false

  def expand(node, params \\ %{})

  def expand({tag, attrs, children}, params) do
    case Keyword.pop(attrs, :if) do
      {nil, attrs} ->
        {tag, expand_attrs(attrs, params), expand(children, params)}

      {expr, attrs} ->
        {:choose, [name: expr],
         [
           {:value, [name: "true"],
            [
              {tag, expand_attrs(attrs, params), expand(children, params)}
            ]},
           {:otherwise, [],
            [
              {:div, [], []}
            ]}
         ]}
    end
  end

  def expand(nodes, params) when is_list(nodes), do: Enum.map(nodes, &expand(&1, params))

  def expand(value, _params) when is_atom(value) or is_number(value) or is_binary(value),
    do: value

  defp expand_attrs(attrs, params) do
    for {name, value} <- attrs do
      value = expand(value, params)
      {name, value}
    end
  end
end

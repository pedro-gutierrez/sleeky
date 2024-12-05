defmodule Sleeky.Ui.View.Resolve do
  @moduledoc false

  def resolve({:component, [name: component], slots}, params) do
    more_params = slot_values(slots)
    params = Map.merge(params, more_params)

    component.source() |> resolve(params)
  end

  def resolve({:slot, _, [name]}, params) do
    case Map.get(params, name) do
      nil ->
        {:div, [], []}

      component when is_atom(component) ->
        component.source() |> resolve(params)

      nodes when is_list(nodes) ->
        resolve(nodes, params)
    end
  end

  def resolve({:each, attrs, [{_, _, _} = child]}, params) do
    alias = attrs |> Keyword.fetch!(:name) |> to_string()
    collection = attrs |> Keyword.fetch!(:in) |> to_string()

    params
    |> Map.get(collection, [])
    |> Enum.map(&resolve(child, Map.put(params, alias, &1)))
  end

  def resolve({:each, attrs, [component]}, params) when is_atom(component),
    do: resolve({:each, attrs, [component.source()]}, params)

  def resolve({:choose, [name: expr], cases}, params) do
    resolved_cases =
      for {:value, [name: value], result} <- cases,
          into: %{},
          do: {value, result}

    actual = expr |> resolve(params) |> String.trim()

    case Map.get(resolved_cases, actual) do
      [result] ->
        resolve(result, params)

      nil ->
        case for {:otherwise, _, [result]} <- cases, do: result do
          [] ->
            {:div, [], []}

          [result] ->
            resolve(result, params)
        end
    end
  end

  def resolve({tag, attrs, children}, params) do
    {tag, resolve_attrs(attrs, params), Enum.map(children, &resolve(&1, params))}
  end

  def resolve(nodes, params) when is_list(nodes), do: Enum.map(nodes, &resolve(&1, params))

  def resolve(text, params) when is_binary(text),
    do: :bbmustache.render(text, params, key_type: :binary)

  def resolve(value, _params) when is_atom(value) or is_number(value), do: to_string(value)

  defp resolve_attrs(attrs, params) do
    for {name, value} <- attrs do
      value = resolve(value, params)
      {name, value}
    end
  end

  defp slot_values(params) do
    for {:slot, [name: name], value} <- params, into: %{} do
      value =
        case value do
          [component] when is_atom(component) -> component
          values when is_list(values) -> values
        end

      {name, value}
    end
  end
end

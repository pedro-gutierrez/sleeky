defmodule Sleeky.Ui.View.Resolve do
  @moduledoc false

  @empty {:span, [], []}

  def resolve({:component, [name: component, using: slot], _}, params) do
    slot = resolve(slot, params)
    params = Map.get(params, slot, %{})

    component.source() |> resolve(params)
  end

  def resolve({:component, [], [component]}, params) do
    component.source() |> resolve(params)
  end

  def resolve({:component, [name: component], slots}, params) do
    more_params = slot_values(slots)
    params = Map.merge(params, more_params)

    component.source() |> resolve(params)
  end

  def resolve({:slot, _, [name]}, params) do
    case Map.get(params, to_string(name)) do
      nil ->
        @empty

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

  def resolve({tag, attrs, children}, params) do
    attrs = resolve_attrs(attrs, params)

    case Keyword.pop(attrs, :if) do
      {nil, attrs} ->
        case Keyword.pop(attrs, :unless) do
          {nil, attrs} ->
            {tag, attrs, resolve(children, params)}

          {expr, attrs} ->
            if expr |> resolve(params) |> falsy?() do
              {tag, attrs, resolve(children, params)}
            else
              @empty
            end
        end

      {expr, attrs} ->
        if expr |> resolve(params) |> truthy?() do
          {tag, attrs, resolve(children, params)}
        else
          @empty
        end
    end
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

      {to_string(name), value}
    end
  end

  defp truthy?(nil), do: false
  defp truthy?(""), do: false
  defp truthy?("false"), do: false
  defp truthy?(_), do: true

  defp falsy?(value), do: not truthy?(value)
end

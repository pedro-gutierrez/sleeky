defmodule Sleeky.Ui.View.Resolve do
  @moduledoc false

  @empty {:span, [], []}

  def resolve({:component, [{:name, component}, {:using, slot} | _] = opts, _}, params) do
    alias = Keyword.get(opts, :as)

    params =
      case resolve_value(slot, params) || %{} do
        more_params when is_map(more_params) ->
          if alias do
            Map.put(more_params, alias, more_params)
          else
            Map.merge(params, more_params)
          end

        values when is_list(values) ->
          if alias do
            Map.put(params, alias, values)
          else
            Map.put(params, slot, values)
          end
      end

    component.source() |> resolve(params)
  end

  def resolve({:component, [], [component]}, params) do
    component.source() |> resolve(params)
  end

  def resolve({:component, [name: component], slots}, params) do
    more_params = resolve_slots(slots, params)
    params = Map.merge(params, more_params)

    component.source() |> resolve(params)
  end

  def resolve({:component, [{:name, component} | slots], []}, params) do
    more_params = resolve_slots(slots, params)
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
    collection = resolve_value(collection, params) || []

    Enum.map(collection, &resolve(child, Map.put(params, alias, &1)))
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

  defp resolve_slots(slots, params) do
    slots
    |> Enum.map(fn
      {:slot, [name: name], [component]} when is_atom(component) -> {to_string(name), component}
      {:slot, [name: name], value} -> {to_string(name), resolve(value, params)}
      {name, value} -> {to_string(name), resolve(value, params)}
    end)
    |> Enum.into(%{})
  end

  defp resolve_value(path, params) do
    path = path |> resolve(params) |> String.split(".")

    get_in(params, path)
  end

  defp truthy?(nil), do: false
  defp truthy?(""), do: false
  defp truthy?("false"), do: false
  defp truthy?(_), do: true

  defp falsy?(value), do: not truthy?(value)
end

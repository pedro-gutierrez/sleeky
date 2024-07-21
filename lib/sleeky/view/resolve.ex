defmodule Sleeky.View.Resolve do
  @moduledoc false

  alias Sleeky.Template

  def resolve({:using, [name: layout], children}, slots) do
    more_slots =
      for {:slot, [name: name], value} <- children, into: %{} do
        value =
          case value do
            [component] when is_atom(component) -> component
            values when is_list(values) -> values
          end

        {name, value}
      end

    slots = Map.merge(slots, more_slots)

    layout.source() |> resolve(slots)
  end

  def resolve({:slot, _, [name]}, slots) do
    case Map.get(slots, name) do
      nil ->
        {:div, [], []}

      component ->
        component.source() |> resolve(slots)
    end
  end

  def resolve({:each, attrs, [{_, _, _} = child]}, slots) do
    child = resolve(child, slots)
    {:each, attrs, [child]}
  end

  def resolve({:each, attrs, [component]}, slots) when is_atom(component) do
    resolve({:each, attrs, [component.source()]}, slots)
  end

  def resolve({:expand, attrs, [{_, _, _} = child]}, slots) do
    slot = Keyword.fetch!(attrs, :name)
    alias = Keyword.fetch!(attrs, :as)
    items = Map.get(slots, slot, [])

    for item <- items do
      slots =
        slots
        |> Map.put(alias, Map.new(item))
        |> Map.put(:__template__, true)

      resolve(child, slots)
    end
  end

  def resolve({:expand, attrs, [component]}, slots) when is_atom(component) do
    resolve({:expand, attrs, [component.source()]}, slots)
  end

  def resolve({tag, attrs, children}, slots) do
    {tag, resolve_attributes(attrs, slots), Enum.map(children, &resolve(&1, slots))}
  end

  def resolve(text, slots) when is_binary(text) do
    if Map.get(slots, :__template__) do
      Template.render!(text, slots, strict_variables: true)
    else
      text
    end
  end

  def resolve(other, slots), do: other |> to_string() |> resolve(slots)

  defp resolve_attributes(attrs, slots) do
    if Map.get(slots, :__template__) do
      for {name, value} <- attrs do
        {name, Template.render!(value, slots, strict_variables: true)}
      end
    else
      attrs
    end
  end
end

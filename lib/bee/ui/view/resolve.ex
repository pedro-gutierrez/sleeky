defmodule Bee.UI.View.Resolve do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def definition, do: @definition

      def render(args \\ %{}) do
        html =
          args
          |> resolve()
          |> Bee.UI.Html.render()
      end

      def resolve(args \\ %{}) do
        Bee.UI.View.Resolve.resolve(__MODULE__, @definition, args)
      rescue
        e ->
          raise """
          Error rendering view #{inspect(__MODULE__)}:
          #{Exception.format(:error, e, __STACKTRACE__)}"
          """
      end
    end
  end

  def resolve(_view, definition, args) do
    with {node, attrs, children} when is_list(children) <- resolve(definition, args) do
      {node, attrs, List.flatten(children)}
    end
  end

  def resolve({:slot, name, [child]}, args) when is_atom(name) do
    case slot!(name, args) do
      items when is_list(items) ->
        Enum.map(items, fn item ->
          item = Enum.into(item, %{})
          resolve(child, item)
        end)
    end
  end

  def resolve({:slot, [], [name]}, args) when is_atom(name) do
    resolve({:slot, name}, args)
  end

  def resolve({:slot, name}, args) when is_atom(name) do
    name
    |> slot!(args)
    |> resolve(args)
  end

  def resolve({:loop, [], children}, args) do
    resolve({:loop, [:items], children}, args)
  end

  def resolve({:loop, path, children}, args) when is_list(path) do
    path = Enum.map_join(path, ".", &to_string/1)

    {:template,
     [
       "x-for": "item in $store.$.state.#{path}",
       ":key": "item.id"
     ], resolve(children, args)}
  end

  def resolve({:loop, {:slot, _} = path, children}, args) do
    path = resolve(path, args)
    resolve({:loop, path, children}, args)
  end

  def resolve({:loop, path, children}, args) when is_binary(path) do
    path =
      path
      |> sanitize_attr(args)
      |> String.split(".")
      |> Enum.map(&String.to_atom/1)

    resolve({:loop, path, children}, args)
  end

  def resolve({:each, var, children}, args) when is_binary(var) or is_atom(var) do
    var = var |> to_string() |> sanitize_attr(args)

    {:template,
     [
       "x-for": "i in #{var}",
       ":key": "i.id"
     ], resolve(children, args)}
  end

  def resolve({:entity, entity, children}, args) do
    args = Map.put(args, :__entity__, entity)
    resolve(children, args)
  end

  def resolve({:view, view}, args) do
    Code.ensure_compiled!(view)
    view.resolve(args)
  end

  def resolve({:view, [], [view]}, args) do
    Code.ensure_compiled!(view)
    view.resolve(args)
  end

  def resolve({:view, view, slots}, args) do
    Code.ensure_compiled!(view)
    slots = resolve_slots(slots, args)
    args = args |> Map.take([:__entity__]) |> Map.merge(slots)
    view.resolve(args)
  end

  def resolve({node, attrs, children}, args) do
    {node, attrs |> resolve(args) |> sanitize_attrs(args), resolve(children, args)}
  end

  def resolve({node, children}, args) when is_list(children) do
    {node, [], resolve(children, args)}
  end

  def resolve(nodes, args) when is_list(nodes) do
    for n <- nodes, do: resolve(n, args)
  end

  def resolve({name, value}, args) do
    {name, resolve(value, args)}
  end

  def resolve(other, _args) when is_binary(other) or is_number(other) or is_atom(other) do
    other
  end

  def resolve(other, _args) do
    raise """
    Don't know how to resolve markup:
    #{inspect(other)}
    """
  end

  defp resolve_slots(slots, args) do
    resolve_slots(slots, args, fn
      {name, _, value} -> {name, value}
      {name, value} -> {name, value}
    end)
  end

  defp resolve_slots(slots, args, fun) do
    slots
    |> resolve(args)
    |> case do
      args when is_list(args) -> args
      arg -> [arg]
    end
    |> Enum.map(fun)
    |> Enum.into(%{})
  end

  defp slot!(name, args) do
    with nil <- Map.get(args, name) do
      raise "No value for slot #{inspect(name)} in #{inspect(args)}"
    end
  end

  defp sanitize_attrs(attrs, args) do
    for {name, value} <- attrs, do: {name, sanitize_attr(value, args)}
  end

  defp sanitize_attr([value], args), do: sanitize_attr(value, args)

  defp sanitize_attr(value, args) when is_binary(value) do
    args = string_keys(args)

    value
    |> Solid.parse!()
    |> Solid.render!(args, strict_variables: true)
    |> to_string
  rescue
    _ ->
      raise "Error rendering attribute #{value} with args #{inspect(Map.keys(args))}"
  end

  defp sanitize_attr(value, _args)
       when is_boolean(value) or is_number(value),
       do: value

  defp sanitize_attr(value, _args) when is_atom(value), do: to_string(value)

  defp string_keys(map) do
    for {key, value} <- map, into: %{}, do: {to_string(key), value}
  end
end

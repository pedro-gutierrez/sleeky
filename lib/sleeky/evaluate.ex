defmodule Sleeky.Evaluate do
  @moduledoc false

  def evaluate(nil, _), do: nil
  def evaluate(value, []), do: value

  def evaluate(_, %{app: app, env: env, key: key}) do
    app |> Application.fetch_env!(env) |> Keyword.fetch!(key)
  end

  def evaluate(_, {:value, v}), do: v
  def evaluate(%{__struct__: _} = context, [:**]), do: context

  def evaluate(%{__struct__: model} = context, {:path, [field]}) when is_atom(field) do
    case model.field_spec(field) do
      {:error, :unknown_field} ->
        if model.name() == field do
          context
        else
          Map.get(context, field)
        end

      {:ok, _kind, _column} ->
        Map.fetch!(context, field)

      {:ok, :child, _, _} ->
        context
        |> relation(field)
        |> Enum.reject(&is_nil/1)

      {:ok, :parent, _, _, _} ->
        relation(context, field)
    end
  end

  def evaluate(%{__struct__: model} = context, {:path, [:**, ancestor | rest]}) do
    case model.context().shortest_path(model.name(), ancestor) do
      [] ->
        if model.name() == ancestor do
          evaluate(context, {:path, rest})
        else
          nil
        end

      path ->
        evaluate(context, {:path, path ++ rest})
    end
  end

  def evaluate(context, {:path, [:** | _] = path}) do
    Enum.reduce_while(context, nil, fn
      {_, %{__struct__: _} = sub_context}, default ->
        case evaluate(sub_context, {:path, path}) do
          nil -> {:cont, default}
          value -> {:halt, value}
        end

      _, default ->
        {:cont, default}
    end)
  end

  def evaluate(context, {:path, [field | _] = paths}) when is_map(context) and is_list(field) do
    paths
    |> Enum.map(&evaluate(context, {:path, &1}))
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  def evaluate(%{__struct__: model} = context, {:path, [field | rest]}) do
    case model.field_spec(field) do
      {:error, :unknown_field} ->
        nil

      {:ok, _kind, _column} ->
        nil

      {:ok, :child, _, _} ->
        context
        |> relation(field)
        |> Enum.map(&evaluate(&1, {:path, rest}))
        |> List.flatten()
        |> Enum.reject(&is_nil/1)
        |> Enum.uniq()

      {:ok, :parent, _, _, _} ->
        context
        |> relation(field)
        |> evaluate({:path, rest})
    end
  end

  def evaluate(context, {:path, [field | rest]}) when is_map(context) and is_atom(field) do
    context
    |> Map.get(field)
    |> evaluate({:path, rest})
  end

  defp relation(%{__struct__: model, id: id} = context, field) do
    with rel when rel != nil <- Map.get(context, field) do
      if unloaded?(rel) do
        key = {id, field}

        with nil <- Process.get(key) do
          rel = context |> model.context().repo().preload(field) |> Map.get(field)
          Process.put(key, rel)
          rel
        end
      else
        rel
      end
    end
  end

  defp unloaded?(%{__struct__: Ecto.Association.NotLoaded}), do: true
  defp unloaded?(_), do: false
end

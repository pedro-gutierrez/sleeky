defmodule Sleeky.Evaluate do
  @moduledoc false

  alias Sleeky.Model.{Attribute, Relation}

  def evaluate(nil, _), do: nil
  def evaluate(context, {:path, []}), do: context

  def evaluate(%{__struct__: model} = context, {:path, [field] = path}) do
    case model.field(field) do
      {:ok, %Attribute{}} ->
        Map.fetch!(context, field)

      {:ok, %Relation{kind: :child}} ->
        context
        |> relation(field)
        |> Enum.reject(&is_nil/1)

      {:ok, %Relation{kind: :parent}} ->
        relation(context, field)

      {:error, :field_not_found} ->
        raise ArgumentError,
              "no such field #{inspect(field)} in #{inspect(model)}, when evaluating path
          #{inspect(path)} on #{inspect(context)}"
    end
  end

  def evaluate(%{__struct__: model} = context, {:path, [:**, ancestor | rest]}) do
    case model.feature().get_shortest_path(model.name(), ancestor) do
      [] ->
        nil

      path ->
        evaluate(context, {:path, path ++ rest})
    end
  end

  def evaluate(context, {:path, [:**, ancestor | _] = path}) do
    Enum.reduce_while(context, nil, fn
      {^ancestor, value}, _default ->
        {:halt, value}

      {_, %{__struct__: _} = sub_context}, default ->
        case evaluate(sub_context, {:path, path}) do
          nil -> {:cont, default}
          value -> {:halt, value}
        end

      _, default ->
        {:cont, default}
    end)
  end

  # def evaluate(context, {:path, [field | _] = paths}) when is_map(context) and is_list(field) do
  #  paths
  #  |> Enum.map(&evaluate(context, {:path, &1}))
  #  |> List.flatten()
  #  |> Enum.reject(&is_nil/1)
  #  |> Enum.uniq()
  # end

  def evaluate(%{__struct__: model} = context, {:path, [field | rest] = path}) do
    case model.field(field) do
      {:ok, %Attribute{}} ->
        raise ArgumentError,
              "field #{inspect(field)} is not a relation of #{inspect(model)}, when evaluating
          path #{inspect(path)} on #{inspect(context)}"

      {:ok, %Relation{kind: :parent}} ->
        context
        |> relation(field)
        |> evaluate({:path, rest})

      {:ok, %Relation{kind: :child}} ->
        context
        |> relation(field)
        |> Enum.map(&evaluate(&1, {:path, rest}))
        |> List.flatten()
        |> Enum.reject(&is_nil/1)
        |> Enum.uniq()

      {:error, :field_not_found} ->
        raise ArgumentError,
              "no such field #{inspect(field)} in #{inspect(model)}, when evaluating path
          #{inspect(path)} on #{inspect(context)}"
    end
  end

  def evaluate(context, {:path, [field | rest]}) do
    context
    |> Map.get(field)
    |> evaluate({:path, rest})
  end

  def evaluate(_, %{app: app, env: env, key: key}) do
    app |> Application.fetch_env!(env) |> Keyword.fetch!(key)
  end

  def evaluate(_, {:value, v}), do: v

  defp relation(%{__struct__: model, id: id} = context, field) do
    with rel when rel != nil <- Map.get(context, field) do
      if unloaded?(rel) do
        key = {id, field}

        with nil <- Process.get(key) do
          rel = context |> model.feature().repo().preload(field) |> Map.get(field)
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

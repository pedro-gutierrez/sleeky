defmodule Sleeky.QueryBuilder do
  @moduledoc """
  Convenience api on top of Ecto.Query to dynamically build queries by joining, filtering and
    sorting
  """

  defstruct joins: [], filters: []

  import Ecto.Query

  @doc """
  Applies the given builder to the given query

  First, it applies joins, then fitlers, finally sorting
  """
  def build(query, %__MODULE__{} = builder) do
    query
    |> join(builder.joins)
    |> filter(builder.filters)
  end

  @doc """
  Filters the given query, with the given list of filters

  """
  def filter(query, nil), do: query
  def filter(query, filter) when is_list(filter), do: filter(query, {:and, filter})

  def filter(query, filter) do
    filter = filter(filter)

    where(query, ^filter)
  end

  defp filter({:and, filter}) do
    Enum.reduce(filter, nil, fn
      filter, nil ->
        filter(filter)

      filter, prev ->
        compiled = filter(filter)

        dynamic(^prev and ^compiled)
    end)
  end

  defp filter({:or, filter}) do
    Enum.reduce(filter, nil, fn
      filter, nil ->
        filter(filter)

      filter, prev ->
        compiled = filter(filter)

        dynamic(^prev or ^compiled)
    end)
  end

  defp filter({:not, filter}) do
    filter = filter(filter)

    dynamic(not (^filter))
  end

  defp filter({{binding, column}, _, nil}) do
    dynamic([{^binding, x}], is_nil(field(x, ^column)))
  end

  defp filter({{binding, column}, :eq, value}) do
    dynamic([{^binding, x}], field(x, ^column) == ^value)
  end

  defp filter({{binding, column}, :neq, value}) do
    dynamic([{^binding, x}], field(x, ^column) != ^value)
  end

  defp filter({{binding, column}, :gt, value}) do
    dynamic([{^binding, x}], field(x, ^column) > ^value)
  end

  defp filter({{binding, column}, :gte, value}) do
    dynamic([{^binding, x}], field(x, ^column) >= ^value)
  end

  defp filter({{binding, column}, :lt, value}) do
    dynamic([{^binding, x}], field(x, ^column) < ^value)
  end

  defp filter({{binding, column}, :lte, value}) do
    dynamic([{^binding, x}], field(x, ^column) <= ^value)
  end

  defp filter({{binding, column}, :in, values}) when is_list(values) do
    dynamic([{^binding, x}], field(x, ^column) in ^values)
  end

  @doc """
  Joins the given query, with the given list of joins

  """
  def join(query, nil), do: query

  def join(query, joins) when is_list(joins) do
    Enum.reduce(joins, query, fn
      {:join, {remote_model, remote_alias, remote_column}, {local_alias, local_column}}, query ->
        join(query, :inner, [{^local_alias, x}], r in ^remote_model,
          as: ^remote_alias,
          on: field(x, ^local_column) == field(r, ^remote_column)
        )
    end)
  end

  @doc """
  Combines multiple query builders into a single one
  """
  def combine(builders, op) do
    %__MODULE__{
      joins: Enum.flat_map(builders, & &1.joins),
      filters: [{op, Enum.flat_map(builders, & &1.filters)}]
    }
  end
end

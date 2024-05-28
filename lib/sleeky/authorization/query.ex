defmodule Sleeky.Authorization.Query do
  @moduledoc false

  alias Sleeky.Evaluate
  alias Sleeky.Model.Attribute
  alias Sleeky.Model.Relation
  alias Sleeky.QueryBuilder

  @doc """
  Scopes a query that relates to a model.

  If no scope is given, the query itself is returned
  """
  def scope(_model, query, nil, _params), do: query

  def scope(model, query, scope, params) do
    qb = build(model, scope, params)

    QueryBuilder.build(query, qb)
  end

  @doc """
  Transforms the given scope, into a query builder struct
  """
  def build(model, scope, params \\ %{}) do
    case scope.expression.op do
      :one -> combine(model, scope.expression.args, params, :or)
      :all -> combine(model, scope.expression.args, params, :and)
      op -> filter(model, op, scope.expression.args, params)
    end
  end

  defp combine(model, args, params, op) do
    args
    |> Enum.map(&build(model, &1, params))
    |> QueryBuilder.combine(op)
  end

  defp filter(model, op, [{:path, left}, right], params) do
    builder = %QueryBuilder{}
    value = Evaluate.evaluate(params, right)

    binding = model.name()

    filter(model, binding, left, op, value, builder)
  end

  defp filter(model, binding, [:**, field | rest], op, value, builder) do
    case model.context().shortest_path(model.name(), field) do
      [] ->
        raise ArgumentError, "no path to #{inspect(field)} in model #{inspect(model)}"

      path ->
        filter(model, binding, path ++ rest, op, value, builder)
    end
  end

  defp filter(model, binding, [field], op, value, builder) do
    case model.field(field) do
      {:ok, %Attribute{} = attr} ->
        filter = {{binding, attr.column_name}, op, value}

        %{builder | filters: builder.filters ++ [filter]}

      {:ok, %Relation{kind: :parent} = rel} ->
        filter = {{binding, rel.column_name}, op, value.id}

        %{builder | filters: builder.filters ++ [filter]}

      {:ok, %Relation{kind: :child} = rel} ->
        join = {:join, {rel.target.module, rel.name, rel.inverse.column_name}, {binding, :id}}
        filter = {{rel.name, :id}, op, value}

        %{builder | joins: builder.joins ++ [join], filters: builder.filters ++ [filter]}
    end
  end

  defp filter(model, binding, [field | rest], op, value, builder) do
    case model.field(field) do
      {:ok, %Relation{kind: :parent} = rel} ->
        parent_model = rel.target.module
        join = {:join, {parent_model, rel.name, :id}, {binding, rel.column_name}}
        builder = %{builder | joins: builder.joins ++ [join]}

        filter(parent_model, rel.name, rest, op, value, builder)

      {:ok, %Relation{kind: :child} = rel} ->
        child_model = rel.target.module
        join = {:join, {child_model, rel.name, rel.inverse.column_name}, {binding, :id}}
        builder = %{builder | joins: builder.joins ++ [join]}

        filter(child_model, rel.name, rest, op, value, builder)
    end
  end
end

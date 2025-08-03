defmodule Sleeky.Scopes.Query do
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

    binding = [model.name()]

    do_filter(model, binding, left, op, value, builder)
  end

  defp do_filter(model, binding, [:**, field | rest], op, value, builder) do
    case model.context().get_shortest_path(model.name(), field) do
      [] ->
        raise ArgumentError, "no path to #{inspect(field)} in model #{inspect(model)}"

      path ->
        do_filter(model, binding, path ++ rest, op, value, builder)
    end
  end

  defp do_filter(model, binding, [field], op, value, builder) do
    case model.field(field) do
      {:ok, %Attribute{} = attr} ->
        binding_alias = binding_alias(binding)
        filter = {{binding_alias, attr.column_name}, op, value}

        %{builder | filters: builder.filters ++ [filter]}

      {:ok, %Relation{kind: :parent} = rel} ->
        binding_alias = binding_alias(binding)
        filter = {{binding_alias, rel.column_name}, op, value.id}

        %{builder | filters: builder.filters ++ [filter]}

      {:ok, %Relation{kind: :child} = rel} ->
        parent_binding = binding
        parent_alias = binding_alias(parent_binding)
        child_binding = binding ++ [rel.name]
        child_alias = binding_alias(child_binding)

        join =
          {:left_join, {rel.target.module, child_alias, rel.inverse.column_name},
           {parent_alias, :id}}

        filter = {{child_alias, :id}, op, value}

        %{builder | joins: builder.joins ++ [join], filters: builder.filters ++ [filter]}
    end
  end

  defp do_filter(model, binding, [field | rest], op, value, builder) do
    case model.field(field) do
      {:ok, %Relation{kind: :parent} = rel} ->
        parent_binding = binding ++ [rel.name]
        parent_binding_alias = binding_alias(parent_binding)
        binding_alias = binding_alias(binding)
        parent_model = rel.target.module
        join_type = if rel.required?, do: :join, else: :left_join

        join =
          {join_type, {parent_model, parent_binding_alias, :id}, {binding_alias, rel.column_name}}

        builder = %{builder | joins: builder.joins ++ [join]}

        do_filter(parent_model, parent_binding, rest, op, value, builder)

      {:ok, %Relation{kind: :child} = rel} ->
        parent_binding = binding
        parent_alias = binding_alias(parent_binding)
        child_binding = binding ++ [rel.name]
        child_alias = binding_alias(child_binding)
        child_model = rel.target.module

        join =
          {:left_join, {child_model, child_alias, rel.inverse.column_name}, {parent_alias, :id}}

        builder = %{builder | joins: builder.joins ++ [join]}

        do_filter(child_model, child_binding, rest, op, value, builder)
    end
  end

  defp binding_alias(binding) do
    binding
    |> Enum.map_join("_", &to_string/1)
    |> String.to_atom()
  end
end

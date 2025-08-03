defmodule Sleeky.Scopes.Query do
  @moduledoc false

  alias Sleeky.Evaluate
  alias Sleeky.Entity.Attribute
  alias Sleeky.Entity.Relation
  alias Sleeky.QueryBuilder

  @doc """
  Scopes a query that relates to a entity.

  If no scope is given, the query itself is returned
  """
  def scope(_entity, query, nil, _params), do: query

  def scope(entity, query, scope, params) do
    qb = build(entity, scope, params)

    QueryBuilder.build(query, qb)
  end

  @doc """
  Transforms the given scope, into a query builder struct
  """
  def build(entity, scope, params \\ %{}) do
    case scope.expression.op do
      :one -> combine(entity, scope.expression.args, params, :or)
      :all -> combine(entity, scope.expression.args, params, :and)
      op -> filter(entity, op, scope.expression.args, params)
    end
  end

  defp combine(entity, args, params, op) do
    args
    |> Enum.map(&build(entity, &1, params))
    |> QueryBuilder.combine(op)
  end

  defp filter(entity, op, [{:path, left}, right], params) do
    builder = %QueryBuilder{}
    value = Evaluate.evaluate(params, right)

    binding = [entity.name()]

    do_filter(entity, binding, left, op, value, builder)
  end

  defp do_filter(entity, binding, [:**, field | rest], op, value, builder) do
    case entity.context().get_shortest_path(entity.name(), field) do
      [] ->
        raise ArgumentError, "no path to #{inspect(field)} in entity #{inspect(entity)}"

      path ->
        do_filter(entity, binding, path ++ rest, op, value, builder)
    end
  end

  defp do_filter(entity, binding, [field], op, value, builder) do
    case entity.field(field) do
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

  defp do_filter(entity, binding, [field | rest], op, value, builder) do
    case entity.field(field) do
      {:ok, %Relation{kind: :parent} = rel} ->
        parent_binding = binding ++ [rel.name]
        parent_binding_alias = binding_alias(parent_binding)
        binding_alias = binding_alias(binding)
        parent_entity = rel.target.module
        join_type = if rel.required?, do: :join, else: :left_join

        join =
          {join_type, {parent_entity, parent_binding_alias, :id},
           {binding_alias, rel.column_name}}

        builder = %{builder | joins: builder.joins ++ [join]}

        do_filter(parent_entity, parent_binding, rest, op, value, builder)

      {:ok, %Relation{kind: :child} = rel} ->
        parent_binding = binding
        parent_alias = binding_alias(parent_binding)
        child_binding = binding ++ [rel.name]
        child_alias = binding_alias(child_binding)
        child_entity = rel.target.module

        join =
          {:left_join, {child_entity, child_alias, rel.inverse.column_name}, {parent_alias, :id}}

        builder = %{builder | joins: builder.joins ++ [join]}

        do_filter(child_entity, child_binding, rest, op, value, builder)
    end
  end

  defp binding_alias(binding) do
    binding
    |> Enum.map_join("_", &to_string/1)
    |> String.to_atom()
  end
end

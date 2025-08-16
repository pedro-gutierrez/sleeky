defmodule Sleeky.Scope do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Scope.Dsl,
    parser: Sleeky.Scope.Parser,
    generators: [
      Sleeky.Scope.Generator.Metadata,
      Sleeky.Scope.Generator.Allowed,
      Sleeky.Scope.Generator.Scope
    ]

  alias Sleeky.Compare
  alias Sleeky.Evaluate
  alias Sleeky.Model.Attribute
  alias Sleeky.Model.Relation
  alias Sleeky.QueryBuilder
  alias Sleeky.Scope.Expression

  defmodule Expression do
    @moduledoc false
    defstruct [:op, :args]
  end

  defstruct [:name, :debug, :expression]

  @doc """
  Evaluates the scope expression against the given context, using boolean logic
  """
  def evaluate(scope, context), do: evaluate(scope, scope.expression(), context)

  defp evaluate(scope, %Expression{op: :one} = expr, context) do
    Enum.reduce_while(expr.args, nil, fn arg, _ ->
      if evaluate(scope, arg, context) do
        {:halt, true}
      else
        {:cont, false}
      end
    end)
  end

  defp evaluate(scope, %Expression{op: :all} = expr, context) do
    Enum.reduce_while(expr.args, nil, fn arg, _ ->
      if evaluate(scope, arg, context) do
        {:cont, true}
      else
        {:halt, false}
      end
    end)
  end

  defp evaluate(scope, %Expression{} = expr, context) do
    values = Enum.map(expr.args, &Evaluate.evaluate(context, &1))

    result = Compare.compare(expr.op, values)

    if scope.debug?() do
      IO.inspect(
        scope: scope,
        args: expr.args,
        values: values,
        op: expr.op,
        context: context,
        result: result
      )
    end

    result
  end

  @doc """
  Applies the scope to the given queryable.
  """
  def scope(scope, model, context) do
    query = model.query()
    expression = scope.expression()

    qb = query_builder(model, expression, context)
    QueryBuilder.build(query, qb)
  end

  @doc """
  Transforms the given scope expression, into a query builder struct
  """
  def query_builder(model, expr, context \\ %{})

  def query_builder(model, %Expression{} = expr, context) do
    case expr.op do
      :one -> combine(model, expr.args, context, :or)
      :all -> combine(model, expr.args, context, :and)
      op -> filter(model, op, expr.args, context)
    end
  end

  def query_builder(model, scope, context) when is_atom(scope) do
    query_builder(model, scope.expression(), context)
  end

  defp combine(model, args, context, op) do
    args
    |> Enum.map(&query_builder(model, &1, context))
    |> QueryBuilder.combine(op)
  end

  defp filter(model, op, [{:path, left}, right], context) do
    builder = %QueryBuilder{}
    value = Evaluate.evaluate(context, right)

    binding = [model.name()]

    do_filter(model, binding, left, op, value, builder)
  end

  defp do_filter(model, binding, [:**, field | rest], op, value, builder) do
    case model.feature().get_shortest_path(model.name(), field) do
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
        value = with %{id: id} <- value, do: id
        filter = {{binding_alias, rel.column_name}, op, value}

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

      {:error, :field_not_found} ->
        raise "Error scoping query on #{inspect(model)}. Trying to access unknown field #{inspect(field)}"
    end
  end

  defp do_filter(model, binding, [field | rest] = path, op, value, builder) do
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

      {:error, :field_not_found} ->
        raise "Error scoping query on #{inspect(model)}. Trying to access unknown field #{inspect(field)} (in expression #{inspect(path)})"
    end
  end

  defp binding_alias(binding) do
    binding
    |> Enum.map_join("_", &to_string/1)
    |> String.to_atom()
  end
end

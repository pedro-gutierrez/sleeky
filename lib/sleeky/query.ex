defmodule Sleeky.Query do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Query.Dsl,
    parser: Sleeky.Query.Parser,
    generators: [
      Sleeky.Query.Generator.Apply,
      Sleeky.Query.Generator.Execute,
      Sleeky.Query.Generator.Handle,
      Sleeky.Query.Generator.Metadata,
      Sleeky.Query.Generator.Scope
    ]

  alias Sleeky.QueryBuilder

  defstruct [
    :name,
    :feature,
    :params,
    :sorting,
    :model,
    :policies,
    :limit,
    :many,
    :custom,
    :debug
  ]

  defmodule Policy do
    @moduledoc false
    defstruct [:role, :scope]
  end

  defmodule Sort do
    @moduledoc false
    defstruct [:field, :direction]
  end

  import Ecto.Query
  import Sleeky.Maps

  @doc """
  Returns the feature function name for a query
  """
  def fun_name(query) do
    query
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.to_atom()
  end

  @doc """
  Builds a query based on the model of the given query

  The query is enhanced with filters derived from the policies and scopes of the query. If however the query does not define any policy, then scoping is skipped.
  """
  def scope(query, context) do
    model = query.model()

    with false <- Enum.empty?(query.policies()),
         {:ok, [_ | _] = roles} <- query.feature().app().roles_from_context(context) do
      scope(model, roles, query.policies(), context)
    else
      true -> model
      {:ok, []} -> model
      {:error, :no_such_roles_path} -> nothing(model)
    end
  end

  defp scope(model, roles, policies, context) do
    policies =
      roles
      |> Enum.map(&Map.get(policies, &1))
      |> Enum.reject(&is_nil/1)

    if policies == [] do
      nothing(model)
    else
      Enum.reduce(policies, model, &scope_with(&1, &2, context))
    end
  end

  defp scope_with(policy, model, context) do
    if policy.scope do
      policy.scope.scope(model, context)
    else
      model
    end
  end

  defp nothing(model), do: where(model, false)

  @doc """
  Executes the query with the given parameters and context
  """
  def execute(query, params, context) do
    params = Map.new(params)

    with {:ok, params} <- query.params().validate(params),
         context <- Map.put(context, :params, params) do
      if query.custom?() do
        params
        |> query.handle(context)
        |> maybe_map_result(query)
        |> maybe_unwrap_result(query)
      else
        context
        |> query.scope()
        |> query.apply_filters(params)
        |> query.apply_sorting()
        |> query.handle(params, context)
        |> call_repo(query, context)
      end
    end
  end

  @doc """
  Executes the query that has no params
  """
  def execute(query, context) do
    if query.custom?() do
      context
      |> query.handle()
      |> maybe_map_result(query)
      |> maybe_unwrap_result(query)
    else
      context
      |> query.scope()
      |> query.apply_sorting()
      |> query.handle(context)
      |> call_repo(query, context)
    end
  end

  defp call_repo(queriable, query, _context) do
    repo = query.feature().repo()

    if query.debug?() do
      IO.inspect(query: query, computed: queriable)
    end

    if query.many?() do
      queriable |> repo.all()
    else
      case repo.one(queriable) do
        nil -> {:error, :not_found}
        item -> {:ok, item}
      end
    end
  end

  defp maybe_map_result(item, query) do
    case query.model() do
      nil -> item
      model -> map_result(item, query, model)
    end
  end

  defp map_result(item, query, model), do: query.feature().map(Map, model, item)

  defp maybe_unwrap_result({:ok, items}, _query) when is_list(items), do: items
  defp maybe_unwrap_result(other, _query), do: other

  @doc """
  Builds a query by taking the parameters and adding them as filters
  """
  def apply_filters(_query, q, params) do
    filters =
      for {field, value} <- plain_map(params) do
        {field, :eq, value}
      end

    Sleeky.QueryBuilder.filter(q, filters)
  end

  @doc """
  Applies sorting to the query
  """
  def apply_sorting(query, q) do
    sorting =
      for %{field: field, direction: direction} <- query.sorting() do
        {field, direction}
      end

    QueryBuilder.sort(q, sorting)
  end
end

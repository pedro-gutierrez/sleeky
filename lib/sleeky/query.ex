defmodule Sleeky.Query do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Query.Dsl,
    parser: Sleeky.Query.Parser,
    generators: [
      Sleeky.Query.Generator.Scope,
      Sleeky.Query.Generator.Metadata
    ]

  defstruct [:name, :feature, :params, :model, :policies, :handler, :limit, :many]

  defmodule Policy do
    @moduledoc false
    defstruct [:role, :scope]
  end

  import Ecto.Query

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

  The query is enhanced with filters derived from the policies and scopes of the query
  """
  def scope(query, context) do
    model = query.model()

    case query.feature().app().roles_from_context(context) do
      {:ok, []} ->
        model

      {:ok, roles} ->
        scope(model, roles, query.policies(), context)

      {:error, :no_such_roles_path} ->
        nothing(model)
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
end

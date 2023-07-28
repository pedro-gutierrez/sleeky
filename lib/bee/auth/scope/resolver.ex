defmodule Sleeki.Auth.Scope.Resolver do
  @moduledoc false
  alias Sleeki.Auth

  import Sleeki.Inspector

  def scopes(auth) do
    scopes =
      auth
      |> Auth.scopes!()
      |> indexed()

    for {name, scope} <- scopes, into: %{} do
      {name, expression(scope.expression, scopes)}
    end
    |> Map.put_new(:any, :allow)
    |> Map.put_new(:none, :deny)
  end

  defp expression(%{op: _, prop: _, value: _} = expr, _scopes) do
    expr
  end

  defp expression(%{all: list}, scopes) when is_list(list) do
    %{all: Enum.map(list, &expression(&1, scopes))}
  end

  defp expression(%{any: list}, scopes) when is_list(list) do
    %{any: Enum.map(list, &expression(&1, scopes))}
  end

  defp expression(name, scopes) when is_atom(name) do
    case Map.get(scopes, name) do
      nil ->
        raise "referenced scope #{inspect(name)} does not exist in: #{inspect(Map.keys(scopes))}"

      scope ->
        expression(scope, scopes)
    end
  end

  defp expression(other, _) do
    raise "invalid scope expression: #{inspect(other)}"
  end
end

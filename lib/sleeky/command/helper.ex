defmodule Sleeky.Command.Helper do
  @moduledoc false

  def fun_name(command) do
    command
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.to_atom()
  end

  def allowed?(command, context) do
    case command.feature().app().roles_from_context(context) do
      {:ok, []} ->
        true

      {:ok, roles} ->
        allowed(roles, command.policies(), context)

      _ ->
        false
    end
  end

  defp allowed(roles, policies, context) do
    policies =
      roles
      |> Enum.map(&Map.get(policies, &1))
      |> Enum.reject(&is_nil/1)

    if policies == [] do
      false
    else
      Enum.reduce_while(policies, false, fn policy, _ ->
        if !policy.scope || policy.scope.allowed?(context) do
          {:halt, true}
        else
          {:cont, false}
        end
      end)
    end
  end
end

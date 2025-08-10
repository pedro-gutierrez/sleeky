defmodule Sleeky.Command do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Command.Dsl,
    generators: [
      Sleeky.Command.Generator.Metadata,
      Sleeky.Command.Generator.Allow,
      Sleeky.Command.Generator.Execute
    ]

  defstruct [:name, :feature, :params, :policies, :atomic?, :steps]

  defmodule Policy do
    @moduledoc false
    defstruct [:role, :scope]
  end

  defmodule Step do
    @moduledoc false
    defstruct [:name, :tasks, :events]
  end

  defmodule Task do
    @moduledoc false
    defstruct [:module]
  end

  defmodule Event do
    @moduledoc false
    defstruct [:module]
  end

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

  @doc """
  Executes the given command

  This function reduces over all the steps defined for the task, perform tasks and collects events
  to be emitted later

  This function returns one of the following results:

  * `{:ok, term()}` - The command was executed successfully and returned a result, but no events
  * `{:ok, term(), events()}` - The command was executed successfully and returned a result, and a list of events
  * `{:error, term()}` - The command failed to execute and the reason is provided.
  """
  def execute(command, params, context) do
  end
end

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

  defstruct [:name, :fun_name, :feature, :params, :returns, :policies, :atomic?, :handler, :events]

  defmodule Policy do
    @moduledoc false
    defstruct [:role, :scope]
  end

  defmodule Event do
    @moduledoc false
    defstruct [:module, :source, :mapping]
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

  * `{:ok, term(), [events]}` - The command was executed successfully and returned a result, and a list of events
  * `{:error, term()}` - The command failed to execute and the reason is provided.
  """
  def execute(command, params, context) do
    with {:ok, result} <- execute_command(command, params, context),
         {:ok, events} <- maybe_create_events(command.events(), result, context) do
      {:ok, result, events}
    end
  end

  defp execute_command(command, params, context) do
    with :ok <- command.handler().execute(params, context) do
      {:ok, params}
    end
  end

  defp maybe_create_events([], _result, _context), do: {:ok, []}

  defp maybe_create_events(events, result, context) do
    result = to_plain_map(result)
    data = Map.merge(result, context)

    with events when is_list(events) <-
           Enum.reduce_while(events, [], fn event, events ->
             case event.mapping.map(data) do
               {:ok, event} -> {:cont, [event | events]}
               {:error, reason} -> {:halt, {:error, reason}}
             end
           end),
         do: {:ok, Enum.reverse(events)}
  end

  defp to_plain_map(data) when is_struct(data), do: Map.from_struct(data)
  defp to_plain_map(data) when is_map(data), do: data
end

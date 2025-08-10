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

  * `{:ok, term(), events()}` - The command was executed successfully and returned a result, and a list of events
  * `{:error, term()}` - The command failed to execute and the reason is provided.
  """
  def execute(command, params, context) do
    case command.steps() do
      [] ->
        # No steps defined, return success without events
        {:ok, nil}

      steps ->
        # Reduce over steps, executing tasks and collecting events
        Enum.reduce_while(steps, {:ok, nil, []}, fn step, {:ok, _result, events} ->
          case execute_step(step, params, context) do
            {:ok, step_result, step_events} ->
              {:cont, {:ok, step_result, events ++ step_events}}

            {:error, reason} ->
              {:halt, {:error, reason}}
          end
        end)
        |> case do
          {:ok, final_result, []} -> {:ok, final_result}
          {:ok, final_result, events} -> {:ok, final_result, events}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp execute_step(step, params, context) do
    # Execute all tasks in the step
    task_result =
      Enum.reduce_while(step.tasks, {:ok, nil}, fn task, {:ok, _} ->
        case task.module.execute(params, context) do
          {:ok, result} -> {:cont, {:ok, result}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)

    with {:ok, result} <- task_result,
         {:ok, events} <- create_event_structs(step.events, result, params) do
      {:ok, result, events}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp create_event_structs(event_definitions, result, params) do
    Enum.reduce_while(event_definitions, {:ok, []}, fn event_def, {:ok, acc} ->
      event_data = params |> Map.merge(result || %{}) |> to_plain_map()

      case event_def.module.new(event_data) do
        {:ok, event_struct} ->
          {:cont, {:ok, [event_struct | acc]}}

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, events} -> {:ok, Enum.reverse(events)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp to_plain_map(data) when is_struct(data), do: Map.from_struct(data)
  defp to_plain_map(data) when is_map(data), do: data
end

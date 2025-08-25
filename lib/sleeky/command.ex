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

  defstruct [
    :name,
    :fun_name,
    :feature,
    :params,
    :returns,
    :policies,
    :atomic?,
    :handler,
    :events
  ]

  import Sleeky.Maps

  defmodule Policy do
    @moduledoc false
    defstruct [:role, :scope]
  end

  defmodule Event do
    @moduledoc false
    defstruct [:module, :source, :mapping, :if, :unless]
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
         {:ok, events} <-
           maybe_create_events(command.feature(), command.events(), result, context) do
      {:ok, result, events}
    end
  end

  defp execute_command(command, params, context) do
    with :ok <- command.handle(params, context) do
      {:ok, params}
    end
  end

  defp maybe_create_events(_feature, [], _result, _context), do: {:ok, []}

  defp maybe_create_events(feature, events, result, context) do
    with events when is_list(events) <-
           Enum.reduce_while(events, [], fn event, events ->
             case maybe_create_event(feature, event, result, context) do
               nil -> {:cont, events}
               {:ok, event} -> {:cont, [event | events]}
               {:error, reason} -> {:halt, {:error, reason}}
             end
           end),
         do: {:ok, Enum.reverse(events)}
  end

  defp maybe_create_event(feature, event, result, context) do
    if_expr = event.if
    unless_expr = event.unless

    maybe_create_event(feature, event, result, context, if_expr, unless_expr)
  end

  defp maybe_create_event(feature, event, result, context, nil, nil),
    do: create_event(feature, event, result, context)

  defp maybe_create_event(feature, event, result, context, if_expr, nil) do
    if if_expr.execute(result, context), do: create_event(feature, event, result, context)
  end

  defp maybe_create_event(feature, event, result, context, nil, unless_expr) do
    if not unless_expr.execute(result, context), do: create_event(feature, event, result, context)
  end

  defp maybe_create_event(feature, event, result, context, if_expr, unless_expr) do
    if not unless_expr.execute(result, context) && if_expr.execute(result, context),
      do: create_event(feature, event, result, context)
  end

  defp create_event(feature, event, result, context) do
    data = result |> plain_map() |> Map.merge(context)

    feature.map(event.source, event.module, data)
  end
end

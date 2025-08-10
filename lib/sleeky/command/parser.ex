defmodule Sleeky.Command.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Command
  alias Sleeky.Command.Policy
  alias Sleeky.Command.Step
  alias Sleeky.Command.Task
  alias Sleeky.Command.Event

  import Sleeky.Feature.Naming

  def parse({:command, attrs, children}, opts) do
    name = Keyword.fetch!(opts, :caller_module)
    caller = Keyword.fetch!(opts, :caller_module)
    feature = feature_module(caller)

    params = Keyword.fetch!(attrs, :params)

    policies =
      for {:policy, attrs, _scopes} <- children do
        role = Keyword.fetch!(attrs, :role)
        scope = Keyword.get(attrs, :scope)

        %Policy{role: role, scope: scope}
      end

    policies =
      for policy <- policies, into: %{} do
        {policy.role, policy}
      end

    steps =
      for {:step, step_attrs, step_children} <- children do
        step_name = Keyword.fetch!(step_attrs, :name)

        tasks =
          for {:task, task_attrs, _} <- step_children do
            task_module = Keyword.fetch!(task_attrs, :name)
            %Task{module: task_module}
          end

        events =
          for {:event, event_attrs, _} <- step_children do
            event_module = Keyword.fetch!(event_attrs, :name)
            %Event{module: event_module}
          end

        %Step{name: step_name, tasks: tasks, events: events}
      end

    atomic? = Keyword.get(attrs, :atomic, false)

    %Command{
      name: name,
      feature: feature,
      params: params,
      policies: policies,
      atomic?: atomic?,
      steps: steps
    }
  end
end

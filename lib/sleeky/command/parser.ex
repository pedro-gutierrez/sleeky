defmodule Sleeky.Command.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Command
  alias Sleeky.Command.Policy
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

    handler =
      caller
      |> Module.split()
      |> Enum.map(fn
        "Commands" -> "Handlers"
        part -> part
      end)
      |> Module.concat()

    events =
      for {:publish, attrs, _} <- children do
        module = Keyword.fetch!(attrs, :name)
        source = Keyword.fetch!(attrs, :from)

        module_last = module |> Module.split() |> List.last() |> Macro.underscore()
        source_last = source |> Module.split() |> List.last() |> Macro.underscore()
        mapping = Macro.camelize("#{module_last}_from_#{source_last}")
        mapping = Module.concat([feature, "Mappings", mapping])

        %Event{module: module, mapping: mapping, source: source}
      end

    atomic? = Keyword.get(attrs, :atomic, false)

    fun_name =
    caller
      |> Module.split()
      |> List.last()
      |> Macro.underscore()
      |> String.to_atom()

    %Command{
      name: name,
      fun_name: fun_name,
      feature: feature,
      params: params,
      policies: policies,
      atomic?: atomic?,
      handler: handler,
      events: events
    }
  end
end

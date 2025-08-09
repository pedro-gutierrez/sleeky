defmodule Sleeky.Command.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Command
  alias Sleeky.Command.Policy

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

    atomic? = Keyword.get(attrs, :atomic, false)

    %Command{
      name: name,
      feature: feature,
      params: params,
      policies: policies,
      atomic?: atomic?
    }
  end
end

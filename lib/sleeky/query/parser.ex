defmodule Sleeky.Query.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Query
  alias Sleeky.Query.Policy
  alias Sleeky.Query.Sort

  import Sleeky.Feature.Naming

  def parse({:query, attrs, children}, opts) do
    name = Keyword.fetch!(opts, :caller_module)
    caller = Keyword.fetch!(opts, :caller_module)
    feature = feature_module(caller)

    params = Keyword.fetch!(attrs, :params)
    model = Keyword.fetch!(attrs, :returns)
    limit = Keyword.get(attrs, :limit)
    many = Keyword.get(attrs, :many, false)
    debug = Keyword.get(attrs, :debug, false)
    custom = Keyword.get(attrs, :custom, false)

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

    sorting =
      for {:sort, opts, _} <- children do
        field = Keyword.fetch!(opts, :by)
        direction = opts[:direction] || :asc

        %Sort{field: field, direction: direction}
      end

    %Query{
      name: name,
      debug: debug,
      feature: feature,
      params: params,
      model: model,
      policies: policies,
      limit: limit,
      many: many,
      custom: custom,
      sorting: sorting
    }
  end
end

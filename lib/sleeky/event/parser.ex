defmodule Sleeky.Event.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Event
  alias Sleeky.Event.Field

  import Sleeky.Feature.Naming

  def parse({:event, attrs, children}, opts) do
    name = Keyword.fetch!(opts, :caller_module)
    caller = Keyword.fetch!(opts, :caller_module)
    feature = feature_module(caller)

    version = Keyword.get(attrs, :version, 1)

    fields =
      for {:field, field_attrs, _} <- children do
        %Field{
          name: Keyword.fetch!(field_attrs, :name),
          type: Keyword.fetch!(field_attrs, :type),
          many: Keyword.get(field_attrs, :many, false),
          default: Keyword.get(field_attrs, :default, nil),
          allowed_values: Keyword.get(field_attrs, :in, []),
          required: Keyword.get(field_attrs, :required, true)
        }
      end

    %Event{
      name: name,
      feature: feature,
      version: version,
      fields: fields
    }
  end
end

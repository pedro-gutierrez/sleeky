defmodule Sleeky.Mapping.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Mapping
  alias Sleeky.Mapping.Field

  import Sleeky.Feature.Naming

  def parse({:mapping, attrs, children}, opts) do
    name = Keyword.fetch!(opts, :caller_module)
    caller = Keyword.fetch!(opts, :caller_module)
    feature = feature_module(caller)

    from = Keyword.fetch!(attrs, :from)
    to = Keyword.fetch!(attrs, :to)

    fields =
      for {:field, field_attrs, _} <- children do
        %Field{
          name: Keyword.fetch!(field_attrs, :name),
          expression: expression(field_attrs)
        }
      end

    %Mapping{
      name: name,
      feature: feature,
      from: from,
      to: to,
      fields: fields
    }
  end

  defp expression(attrs) do
    path = attrs
    |> Keyword.fetch!(:path)
    |> String.split(".")
    |> Enum.map(&String.to_atom/1)

    {:path, path}
  end
end

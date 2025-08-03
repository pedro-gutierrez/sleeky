defmodule Sleeky.Decoder.SortDecoder do
  @moduledoc """
  A generic validator that parses sort queries as maps, using a dsl
  """

  @sort_rules [required: false, nullable: true, type: :string, in: ["asc", "desc"], cast: :atom]

  defmacro __using__(opts) do
    entity = Keyword.fetch!(opts, :entity)
    attrs = entity.attributes() |> Enum.reject(&(&1.name in [:id]))
    rules = for attr <- attrs, into: %{}, do: {to_string(attr.name), @sort_rules}

    quote do
      use Sleeky.Decoder.PairsDecoder, rules: unquote(rules)
    end
  end
end

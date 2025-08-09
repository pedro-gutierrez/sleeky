defmodule Sleeky.Value.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Value
  alias Sleeky.Value.Field

  def parse({:value, _, fields}, _opts) do
    fields =
      for {:field, attrs, _} <- fields do
        %Field{
          name: Keyword.fetch!(attrs, :name),
          type: Keyword.fetch!(attrs, :type),
          default: Keyword.get(attrs, :default, nil),
          allowed_values: Keyword.get(attrs, :in, []),
          required: Keyword.get(attrs, :required, true)
        }
      end

    %Value{fields: fields}
  end
end

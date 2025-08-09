defmodule Sleeky.Projection.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Projection
  alias Sleeky.Projection.Field

  def parse({:projection, _, fields}, _opts) do
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

    %Projection{fields: fields}
  end
end

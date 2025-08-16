defmodule Sleeky.Value.Generator.Functions do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl Diesel.Generator
  def generate(value, _opts) do
    ecto_schema = Sleeky.Value.schema(value)

    quote do
      unquote(ecto_schema)

      def changeset(params), do: Sleeky.Value.changeset(__MODULE__, params)
      def decode(json), do: Sleeky.Value.decode(__MODULE__, json)
      def new(params), do: Sleeky.Value.new(__MODULE__, params)
      def validate(params), do: Sleeky.Value.validate(__MODULE__, params)
    end
  end
end

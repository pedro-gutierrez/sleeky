defmodule Sleeky.Value.Generator.Field do
  @moduledoc false
  @behaviour Diesel.Generator

  alias Sleeky.Model.Attribute

  @impl Diesel.Generator
  def generate(value, _options) do
    attributes =
      value.fields
      |> Enum.flat_map(fn field ->
        attribute = %Attribute{name: field.name, kind: field.type}

        [{field.name, attribute}, {to_string(field.name), attribute}]
      end)
      |> Enum.into(%{})

    quote do
      def field(name), do: Sleeky.Value.field(__MODULE__, name)

      @attributes unquote(Macro.escape(attributes))
      def attributes, do: @attributes
    end
  end
end

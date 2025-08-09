defmodule Sleeky.Value.Generator.Changeset do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(value, _opts) do
    fields = Enum.map(value.fields, & &1.name)
    required_fields = value.fields |> Enum.filter(& &1.required) |> Enum.map(& &1.name)

    quote do
      import Ecto.Changeset

      def changeset(params) do
        %__MODULE__{}
        |> cast(params, unquote(fields))
        |> validate_required(unquote(required_fields))
      end
    end
  end
end

defmodule Sleeky.Projection.Generator.EctoSchema do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(projection, _opts) do
    fields =
      for field <- projection.fields do
        quote do
          Ecto.Schema.field(unquote(field.name), unquote(field.type))
        end
      end

    quote do
      use Ecto.Schema

      @primary_key false
      embedded_schema do
        (unquote_splicing(fields))
      end
    end
  end
end

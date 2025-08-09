defmodule Sleeky.Value.Generator.EctoSchema do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(value, _opts) do
    fields =
      for field <- value.fields do
        quote do
          Ecto.Schema.field(unquote(field.name), unquote(field.type))
        end
      end

    quote do
      use Ecto.Schema

      embedded_schema do
        (unquote_splicing(fields))
      end
    end
  end
end

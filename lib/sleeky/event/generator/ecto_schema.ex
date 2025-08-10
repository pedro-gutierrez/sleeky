defmodule Sleeky.Event.Generator.EctoSchema do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(event, _opts) do
    field_names = Enum.map(event.fields, & &1.name)

    fields =
      for field <- event.fields do
        ecto_type = map_type(field.type)

        quote do
          Ecto.Schema.field(unquote(field.name), unquote(ecto_type))
        end
      end

    quote do
      @derive {Jason.Encoder, only: unquote(field_names)}

      use Ecto.Schema

      @primary_key false
      embedded_schema do
        (unquote_splicing(fields))
      end
    end
  end

  defp map_type(:datetime), do: :utc_datetime_usec
  defp map_type(:id), do: :binary_id
  defp map_type(type), do: type
end

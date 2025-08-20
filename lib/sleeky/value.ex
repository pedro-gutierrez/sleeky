defmodule Sleeky.Value do
  @moduledoc """
  A dsl to define values in the context of DDD
  """

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Value.Dsl,
    generators: [
      Sleeky.Value.Generator.Functions,
      Sleeky.Value.Generator.Metadata,
      Sleeky.Value.Generator.Field
    ]

  defmodule Field do
    @moduledoc false
    defstruct [:name, :type, :many, :required, :default, :allowed_values]
  end

  defstruct [:fields]

  import Ecto.Changeset

  @doc """
  Generates the ecto schema for a value
  """
  def schema(value) do
    field_names = Enum.map(value.fields, & &1.name)

    fields =
      for field <- value.fields do
        ecto_type = map_type(field.type)

        if field.many do
          quote do
            Ecto.Schema.field(unquote(field.name), {:array, unquote(ecto_type)})
          end
        else
          quote do
            Ecto.Schema.field(unquote(field.name), unquote(ecto_type))
          end
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

  defp map_type(:datetime), do: :utc_datetime
  defp map_type(:id), do: :binary_id
  defp map_type(type), do: type

  @doc """
  Validates the value against the given parameters.
  """
  def validate(value, params) do
    changeset = value.changeset(params)

    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end

  @doc """
  Returns a changeset for a value
  """
  def changeset(value, params) do
    fields = value.fields()
    field_names = Enum.map(fields, & &1.name)
    required_field_names = fields |> Enum.filter(& &1.required) |> Enum.map(& &1.name)

    value
    |> struct()
    |> cast(params, field_names)
    |> validate_required(required_field_names)
  end

  @doc """
  Decodes a json string into a value
  """
  def decode(value, json) do
    with {:ok, data} <- Jason.decode(json) do
      value.new(data)
    end
  end

  @doc """
  Creates a new value from a plain map of params
  """
  def new(value, params) do
    params = Map.new(params)

    validate(value, params)
  end

  @doc """
  Returns a field metadata as a model attribute

  This is so that values can be inspected with the evaluate module
  """
  def field(value, name) do
    case value.attributes() |> Map.get(name) do
      nil -> {:error, :field_not_found}
      attr -> {:ok, attr}
    end
  end
end

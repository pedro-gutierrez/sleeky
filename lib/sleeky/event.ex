defmodule Sleeky.Event do
  @moduledoc """
  A DSL to define domain events in the context of DDD and Event Sourcing
  """

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Event.Dsl,
    parser: Sleeky.Event.Parser,
    generators: [
      Sleeky.Event.Generator.EctoSchema,
      Sleeky.Event.Generator.Metadata,
      Sleeky.Event.Generator.Decode,
      Sleeky.Event.Generator.New
    ]

  defmodule Field do
    @moduledoc false
    defstruct [:name, :type, :required, :default, :allowed_values]
  end

  defstruct [:name, :version, :fields, :feature]

  import Ecto.Changeset

  @doc """
  Builds a new event with the given params as fields
  """
  def new(event, params) do
    params = Map.new(params)
    fields = event.fields()
    field_names = Enum.map(fields, & &1.name)
    required_fields = fields |> Enum.filter(& &1.required) |> Enum.map(& &1.name)

    changeset =
      event
      |> struct()
      |> cast(params, field_names)
      |> validate_required(required_fields)

    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end

  def new(params), do: new(Map.new(params))

  @doc """
  Decodes an event from json
  """
  def decode(event, json) do
    with {:ok, data} <- Jason.decode(json) do
      event.new(data)
    end
  end
end

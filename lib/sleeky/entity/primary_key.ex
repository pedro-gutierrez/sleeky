defmodule Sleeky.Entity.PrimaryKey do
  @moduledoc """
  A simple struct to hold the details of the primary key of an entity.

  Key `kind` refers to the abstract field type (eg `:id`) while `storage` represents the actual
    datatype used in the database (eg, `:binary_id`).
  """

  alias Sleeky.Entity.Attribute

  defstruct [:field, :kind, :storage, :implied?]

  @doc """
  A primary key is by default named `id` of type `id`.
  """
  def default, do: %__MODULE__{field: :id, kind: :id, storage: :binary_id, implied?: true}

  @doc """
  Converts the given attribute into a primary key spec
  """
  def for_attribute(%Attribute{} = attr) do
    %__MODULE__{
      field: attr.name,
      kind: attr.kind,
      storage: Attribute.storage(attr.kind, primary_key: true),
      implied?: attr.kind == :id
    }
  end
end

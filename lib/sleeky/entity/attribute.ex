defmodule Sleeky.Entity.Attribute do
  @moduledoc false
  alias Sleeky.Entity.Aliases
  alias Sleeky.Entity.Summary
  import Sleeky.Inspector

  defstruct [
    :name,
    :label,
    :kind,
    :entity,
    :default,
    :storage,
    :plugin,
    :using,
    enum: nil,
    aliases: [],
    column: nil,
    unique?: false,
    required?: true,
    immutable?: false,
    virtual?: false,
    computed?: false,
    timestamp?: false,
    primary_key?: false
  ]

  def new(fields) do
    __MODULE__
    |> struct(fields)
    |> with_label()
    |> with_summary_entity()
    |> with_column()
    |> with_storage()
    |> with_aliases()
    |> maybe_timestamp()
  end

  def id?(attr), do: attr.name == :id

  @doc """
  Translates an abstract field type into its physical storage datatype in the db
  """
  def storage(kind, opts \\ [])
  def storage(:id, _), do: :binary_id
  def storage(:text, _), do: :string
  def storage(:datetime, _), do: :utc_datetime
  def storage(:enum, _), do: :string
  def storage(kind, _), do: kind

  def with_label(attr) do
    %{attr | label: label(attr.name)}
  end

  defp with_summary_entity(attr) do
    %{attr | entity: Summary.new(attr.entity)}
  end

  defp with_column(attr) do
    %{attr | column: attr.name}
  end

  defp with_storage(attr) do
    %{attr | storage: storage(attr.kind)}
  end

  defp with_aliases(attr) do
    Aliases.new(attr)
  end

  def maybe_immutable(attr, do: {:immutable, _, _}) do
    %{attr | immutable?: true}
  end

  def maybe_immutable(attr, _), do: attr

  def maybe_enum(attr, do: {:one_of, _, [enum]}) do
    %{attr | enum: enum}
  end

  def maybe_enum(attr, _), do: attr

  def maybe_primary_key(attr, do: {:primary_key, _, _}) do
    if attr.name != :id do
      raise """
      Attributes marked as primary keys must be named :id.
      Found: #{inspect(attr.name)} in entity #{inspect(attr.entity.module)}
      """
    end

    %{attr | primary_key?: true}
  end

  def maybe_primary_key(attr, _), do: attr

  @timestamps [:inserted_at, :updated_at]

  defp maybe_timestamp(attr), do: %{attr | timestamp?: attr.name in @timestamps}
end

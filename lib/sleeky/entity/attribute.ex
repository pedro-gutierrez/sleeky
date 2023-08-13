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
    implied?: false,
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
  def storage(:id), do: :uuid
  def storage(:text), do: :string
  def storage(:datetime), do: :utc_datetime
  def storage(:enum), do: :string
  def storage(kind), do: kind

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

  defp maybe_timestamp(attr) do
    timestamp = attr.name in [:inserted_at, :updated_at]

    %{attr | timestamp?: timestamp}
  end

  def maybe_immutable(attr, do: {:immutable, _, _}) do
    %{attr | immutable?: true}
  end

  def maybe_immutable(attr, _), do: attr

  def maybe_enum(attr, do: {:one_of, _, [enum]}) do
    %{attr | enum: enum}
  end

  def maybe_enum(attr, _), do: attr
end

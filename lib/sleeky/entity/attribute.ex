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
    implied: false,
    column: nil,
    unique: false,
    required: true,
    immutable: false,
    virtual: false,
    computed: false,
    timestamp: false
  ]

  def new(fields) do
    __MODULE__
    |> struct(fields)
    |> with_label()
    |> with_summary_entity()
    |> with_column()
    |> with_storage()
    |> with_aliases()
    |> maybe_implied()
    |> maybe_timestamp()
  end

  def id?(attr) do
    attr.name == :id
  end

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
    case attr.kind do
      :id ->
        %{attr | storage: :uuid}

      :text ->
        %{attr | storage: :string}

      :datetime ->
        %{attr | storage: :utc_datetime}

      :enum ->
        %{attr | storage: :string}

      kind ->
        %{attr | storage: kind}
    end
  end

  defp with_aliases(attr) do
    Aliases.new(attr)
  end

  defp maybe_implied(attr) do
    implied = attr.name in [:id, :inserted_at, :updated_at]

    %{attr | implied: implied}
  end

  defp maybe_timestamp(attr) do
    timestamp = attr.name in [:inserted_at, :updated_at]

    %{attr | timestamp: timestamp}
  end

  def maybe_immutable(attr, do: {:immutable, _, _}) do
    %{attr | immutable: true}
  end

  def maybe_immutable(attr, _), do: attr

  def maybe_enum(attr, do: {:one_of, _, [enum]}) do
    %{attr | enum: enum}
  end

  def maybe_enum(attr, _), do: attr
end

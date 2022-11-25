defmodule Bee.Entity.Attribute do
  @moduledoc false
  alias Bee.Entity.Aliases
  alias Bee.Entity.Summary

  defstruct [
    :name,
    :kind,
    :entity,
    :default,
    :storage,
    :plugin,
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

  defp with_summary_entity(rel) do
    %{rel | entity: Summary.new(rel.entity)}
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
end

defmodule Bee.Entity.Attribute do
  @moduledoc false
  alias Bee.Entity.Summary

  defstruct [
    :name,
    :kind,
    :entity,
    :default,
    :storage,
    column: nil,
    unique: false,
    required: true,
    immutable: false,
    virtual: false,
    computed: false
  ]

  def new(fields) do
    __MODULE__
    |> struct(fields)
    |> with_summary_entity()
    |> with_column()
    |> with_storage()
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
      :text ->
        %{attr | kind: :string, storage: :text}

      kind ->
        %{attr | storage: kind}
    end
  end
end

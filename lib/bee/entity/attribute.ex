defmodule Bee.Entity.Attribute do
  defstruct [
    :name,
    :kind,
    :entity,
    :default,
    :storage,
    unique: false,
    required: true,
    immutable: false,
    virtual: false,
    computed: false
  ]

  def new(fields) do
    __MODULE__
    |> struct(fields)
    |> with_storage()
  end

  def id?(attr) do
    attr.name == :id
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

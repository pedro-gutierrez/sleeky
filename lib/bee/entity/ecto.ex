defmodule Bee.Entity.Ecto do
  @moduledoc false
  import Bee.Inspector

  @generators [
    Bee.Entity.Ecto.FieldAttributes,
    Bee.Entity.Ecto.Schema,
    Bee.Entity.Ecto.Changesets,
    Bee.Entity.Ecto.FieldSpecs,
    Bee.Entity.Ecto.Slug
  ]

  def ast(entity) do
    attributes = entity.attributes
    parents = entity.parents
    children = entity.children
    keys = entity.keys

    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, :binary_id, autogenerate: false}
      @timestamps_opts [type: :utc_datetime]

      def virtual?, do: false
      def table, do: unquote(entity.table)
      def attributes, do: unquote(Macro.escape(attributes))
      def parents, do: unquote(Macro.escape(parents))
      def children, do: unquote(Macro.escape(children))
      def keys, do: unquote(Macro.escape(keys))

      unquote_splicing(
        @generators
        |> Enum.map(& &1.ast(entity))
        |> flatten()
      )
    end
  end
end

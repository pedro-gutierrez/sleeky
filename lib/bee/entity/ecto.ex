defmodule Bee.Entity.Ecto do
  @moduledoc false
  import Bee.Inspector

  @generators [
    Bee.Entity.Ecto.Helpers,
    Bee.Entity.Ecto.FieldAttributes,
    Bee.Entity.Ecto.Schema,
    Bee.Entity.Ecto.Changesets,
    Bee.Entity.Ecto.FieldSpecs,
    Bee.Entity.Ecto.ColumnSpecs,
    Bee.Entity.Ecto.Pagination,
    Bee.Entity.Ecto.Preload,
    Bee.Entity.Ecto.Relation,
    Bee.Entity.Ecto.Slug,
    Bee.Entity.Ecto.Display,
    Bee.Entity.Ecto.JsonEncoder,
    Bee.Entity.Ecto.List,
    Bee.Entity.Ecto.Read,
    Bee.Entity.Ecto.Create,
    Bee.Entity.Ecto.Update,
    Bee.Entity.Ecto.Delete,
    Bee.Entity.Ecto.Query,
    Bee.Entity.Ecto.Join,
    Bee.Entity.Ecto.Where
  ]

  def ast(entity) do
    auth = entity.auth
    repo = entity.repo
    attributes = entity.attributes
    parents = entity.parents
    children = entity.children
    keys = entity.keys
    actions = entity.actions

    quote do
      use Ecto.Schema

      @auth unquote(auth)
      @repo unquote(repo)

      @primary_key {:id, :binary_id, autogenerate: false}
      @timestamps_opts [type: :utc_datetime]

      def name, do: unquote(entity.name)
      def plural, do: unquote(entity.plural)
      def label, do: unquote(entity.label)
      def virtual?, do: false
      def table, do: unquote(entity.table)
      def attributes, do: unquote(Macro.escape(attributes))
      def parents, do: unquote(Macro.escape(parents))
      def children, do: unquote(Macro.escape(children))
      def keys, do: unquote(Macro.escape(keys))
      def actions, do: unquote(Macro.escape(actions))

      unquote_splicing(
        @generators
        |> Enum.map(& &1.ast(entity))
        |> flatten()
      )
    end
  end
end

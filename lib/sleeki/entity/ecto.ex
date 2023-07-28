defmodule Sleeki.Entity.Ecto do
  @moduledoc false
  import Sleeki.Inspector

  @generators [
    Sleeki.Entity.Ecto.Helpers,
    Sleeki.Entity.Ecto.FieldAttributes,
    Sleeki.Entity.Ecto.Schema,
    Sleeki.Entity.Ecto.Changesets,
    Sleeki.Entity.Ecto.FieldSpecs,
    Sleeki.Entity.Ecto.ColumnSpecs,
    Sleeki.Entity.Ecto.Pagination,
    Sleeki.Entity.Ecto.Preload,
    Sleeki.Entity.Ecto.Relation,
    Sleeki.Entity.Ecto.Slug,
    Sleeki.Entity.Ecto.Display,
    Sleeki.Entity.Ecto.JsonEncoder,
    Sleeki.Entity.Ecto.List,
    Sleeki.Entity.Ecto.Read,
    Sleeki.Entity.Ecto.Create,
    Sleeki.Entity.Ecto.Update,
    Sleeki.Entity.Ecto.Delete,
    Sleeki.Entity.Ecto.Query,
    Sleeki.Entity.Ecto.Join,
    Sleeki.Entity.Ecto.Where,
    Sleeki.Entity.Ecto.FuzzySearch
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
      def plural_label, do: unquote(entity.plural_label)
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

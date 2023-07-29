defmodule Sleeky.Entity.Ecto do
  @moduledoc false
  import Sleeky.Inspector

  @generators [
    Sleeky.Entity.Ecto.Helpers,
    Sleeky.Entity.Ecto.FieldAttributes,
    Sleeky.Entity.Ecto.Schema,
    Sleeky.Entity.Ecto.Changesets,
    Sleeky.Entity.Ecto.FieldSpecs,
    Sleeky.Entity.Ecto.ColumnSpecs,
    Sleeky.Entity.Ecto.Pagination,
    Sleeky.Entity.Ecto.Preload,
    Sleeky.Entity.Ecto.Relation,
    Sleeky.Entity.Ecto.Slug,
    Sleeky.Entity.Ecto.Display,
    Sleeky.Entity.Ecto.JsonEncoder,
    Sleeky.Entity.Ecto.List,
    Sleeky.Entity.Ecto.Read,
    Sleeky.Entity.Ecto.Create,
    Sleeky.Entity.Ecto.Update,
    Sleeky.Entity.Ecto.Delete,
    Sleeky.Entity.Ecto.Query,
    Sleeky.Entity.Ecto.Join,
    Sleeky.Entity.Ecto.Where,
    Sleeky.Entity.Ecto.FuzzySearch
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

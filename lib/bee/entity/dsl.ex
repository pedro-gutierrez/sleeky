defmodule Bee.Entity.Dsl do
  alias Bee.Entity
  alias Bee.Entity.Attribute
  alias Bee.Entity.Key
  alias Bee.Entity.Relation
  import Bee.Entity
  import Bee.Inspector
  import Bee.Opts

  defmacro attribute(name, kind, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    entity =
      [name: name, kind: kind, entity: entity]
      |> Attribute.new()
      |> with_opts(opts)
      |> Attribute.maybe_immutable(opts)
      |> Attribute.maybe_enum(opts)
      |> add_to(:attributes, entity)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro belongs_to(name, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    entity =
      [name: name, kind: :parent, entity: entity]
      |> Relation.new()
      |> with_opts(opts)
      |> add_to(:parents, entity)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro has_many(name, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    entity =
      [name: name, kind: :child, entity: entity]
      |> Relation.new()
      |> with_opts(opts)
      |> add_to(:children, entity)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro unique(fields, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    fields =
      fields
      |> as_list()
      |> fields!(entity)

    entity =
      [fields: fields, entity: entity]
      |> Key.new()
      |> with_opts(opts)
      |> add_to(:keys, entity)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro slug(fields, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    slug_module = Bee.Entity.Ecto.Slug.module(entity)

    fields = as_list(fields)

    attribute =
      [
        name: :slug,
        kind: :string,
        entity: entity,
        computed: true,
        using: slug_module,
        plugin: {Bee.Entity.Ecto.Slug, fields}
      ]
      |> Attribute.new()
      |> with_opts(opts)

    entity = add_to(attribute, :attributes, entity)

    entity =
      [fields: [attribute], entity: entity]
      |> Key.new()
      |> with_opts(opts)
      |> add_to(:keys, entity)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro immutable do
  end
end

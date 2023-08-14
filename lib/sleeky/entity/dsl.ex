defmodule Sleeky.Entity.Dsl do
  @moduledoc """
  The Dsl to build schemas by defining entities, their attributes and their relations to other entities
  """

  alias Sleeky.Entity
  alias Sleeky.Entity.{Attribute, Key, Relation, Action}

  import Sleeky.Entity
  import Sleeky.Inspector
  import Sleeky.Opts

  defmacro action(name, block \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    entity =
      [name: name, entity: entity]
      |> Action.new()
      |> Action.with_policies(block)
      |> add_to(:actions, entity)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro attribute(name, kind, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    entity =
      [name: name, kind: kind, entity: entity]
      |> Attribute.new()
      |> with_opts(opts)
      |> Attribute.maybe_immutable(opts)
      |> Attribute.maybe_primary_key(opts)
      |> Attribute.maybe_implied(opts)
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
      |> Relation.with_inverse()
      |> Relation.with_foreign_key()
      |> with_opts(opts)
      |> add_to(:parents, entity)

    entity = add_to(name, :preloads, entity)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro has_many(name, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    entity =
      [name: name, kind: :child, entity: entity]
      |> Relation.new()
      |> Relation.with_inverse()
      |> Relation.with_foreign_key()
      |> with_opts(opts)
      |> add_to(:children, entity)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro unique(fields, opts \\ []) do
    module = __CALLER__.module
    key(module, fields, true, opts)
  end

  defmacro key(fields, opts \\ []) do
    module = __CALLER__.module
    key(module, fields, false, opts)
  end

  defp key(module, fields, unique, opts) do
    entity = Entity.entity(module)

    fields =
      fields
      |> as_list()
      |> fields!(entity)

    entity =
      [fields: fields, entity: entity, unique: unique]
      |> Key.new()
      |> with_opts(opts)
      |> add_to(:keys, entity)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro slug(fields, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    slug_module = Sleeky.Entity.Ecto.Slug.module(entity)

    fields = as_list(fields)

    attribute =
      [
        name: :slug,
        kind: :string,
        entity: entity,
        computed: true,
        using: slug_module,
        plugin: {Sleeky.Entity.Ecto.Slug, fields}
      ]
      |> Attribute.new()
      |> with_opts(opts)

    entity = add_to(attribute, :attributes, entity)

    entity =
      [fields: [attribute], entity: entity, unique: true]
      |> Key.new()
      |> with_opts(opts)
      |> add_to(:keys, entity)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro immutable do
  end
end

defmodule Bee.Entity.Dsl do
  alias Bee.Entity
  alias Bee.Entity.Attribute
  alias Bee.Entity.Relation
  import Bee.Opts

  defmacro attribute(name, kind, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    attr =
      [name: name, kind: kind, entity: entity]
      |> Attribute.new()
      |> with_opts(opts)

    entity = Entity.with_attribute(entity, attr)

    Module.put_attribute(module, :entity, entity)
  end

  defmacro belongs_to(name, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    rel =
      [name: name, kind: :parent, entity: entity]
      |> Relation.new()
      |> with_opts(opts)

    entity = Entity.with_parent(entity, rel)
    Module.put_attribute(module, :entity, entity)
  end

  defmacro has_many(name, opts \\ nil) do
    module = __CALLER__.module
    entity = Entity.entity(module)

    rel =
      [name: name, kind: :child, entity: entity]
      |> Relation.new()
      |> with_opts(opts)

    entity = Entity.with_child(entity, rel)
    Module.put_attribute(module, :entity, entity)
  end

  defmacro immutable do
  end

  defmacro unique do
  end
end

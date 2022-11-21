defmodule Bee.Entity do
  alias Bee.Entity.Attribute
  alias Bee.Entity.Ecto
  alias Bee.Entity.Virtual
  import Bee.Inspector

  defstruct [
    :context,
    :name,
    :module,
    :plural,
    :table,
    :pk_constraint,
    attributes: [],
    parents: [],
    children: [],
    virtual?: false
  ]

  def new(module) do
    name = name(module)
    plural = plural(name)
    table = plural

    %__MODULE__{
      context: context(module),
      module: module,
      name: name,
      plural: plural,
      table: table,
      pk_constraint: "#{table}_pkey"
    }
  end

  def with_attribute(entity, attr) do
    %{entity | attributes: entity.attributes ++ [attr]}
  end

  def with_parent(entity, rel) do
    %{entity | parents: entity.parents ++ [rel]}
  end

  def with_child(entity, rel) do
    %{entity | children: entity.children ++ [rel]}
  end

  def entity(entity) do
    Module.get_attribute(entity, :entity)
  end

  defmacro __using__(_) do
    module = __CALLER__.module

    entity =
      module
      |> new()
      |> with_attribute(Attribute.new(name: :id, kind: :string))

    Module.register_attribute(module, :entity, persist: true, accumulate: false)
    Module.put_attribute(module, :entity, entity)

    quote do
      import Bee.Entity.Dsl, only: :macros
      @before_compile Bee.Entity
    end
  end

  defmacro __before_compile__(_env) do
    entity = entity(__CALLER__.module)
    generator = if entity.virtual?, do: Virtual, else: Ecto
    generator.ast(entity)
  end
end

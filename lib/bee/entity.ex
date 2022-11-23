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
    keys: [],
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

  def add_to(item, key, entity) do
    values = Map.get(entity, key) ++ [item]
    Map.put(entity, key, values)
  end

  def fields!(names, entity) do
    Enum.map(names, &field!(&1, entity))
  end

  def field!(name, entity) do
    f = field(name, entity)

    unless f do
      raise "No such field #{inspect(name)} in #{inspect(entity.name)}"
    end

    f
  end

  def field(name, entity) do
    Enum.find(entity.attributes ++ entity.parents, &(&1.name == name))
  end

  def entity(entity) do
    Module.get_attribute(entity, :entity)
  end

  defmacro __using__(_) do
    module = __CALLER__.module

    entity = new(module)

    entity =
      [name: :id, kind: :string, entity: entity]
      |> Attribute.new()
      |> add_to(:attributes, entity)

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
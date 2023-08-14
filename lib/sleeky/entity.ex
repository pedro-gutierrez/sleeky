defmodule Sleeky.Entity do
  @moduledoc """
  A entity describes your data.
  """

  alias Sleeky.Entity.Attribute
  alias Sleeky.Entity.Ecto
  alias Sleeky.Entity.PrimaryKey
  alias Sleeky.Entity.Virtual
  import Sleeky.Inspector

  defstruct [
    :context,
    :name,
    :label,
    :module,
    :plural,
    :plural_label,
    :table,
    :schema,
    :repo,
    :auth,
    :pk_constraint,
    :primary_key,
    actions: [],
    attributes: [],
    breadcrumbs: true,
    parents: [],
    children: [],
    keys: [],
    preloads: [],
    virtual?: false
  ]

  def new(module) do
    schema = module |> context()
    schema_context = context(schema)
    repo = module(schema_context, Repo)
    auth = module(schema_context, Auth)
    name = name(module)
    plural = plural(name)
    table = plural

    %__MODULE__{
      context: schema,
      module: module,
      name: name,
      label: Inflex.camelize(name),
      schema: schema,
      repo: repo,
      auth: auth,
      plural: plural,
      plural_label: label(plural),
      table: table,
      primary_key: PrimaryKey.default(),
      pk_constraint: "#{table}_pkey",
      breadcrumbs: true
    }
  end

  def add_to(item, key, entity) do
    values = Map.get(entity, key) ++ [item]
    Map.put(entity, key, values)
  end

  def action(name, entity) do
    Enum.find(entity.actions, &(&1.name == name))
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

  defmacro __using__(_opts) do
    module = __CALLER__.module

    entity = new(module)

    Module.register_attribute(module, :entity, persist: true, accumulate: false)
    Module.put_attribute(module, :entity, entity)

    quote do
      import Sleeky.Entity.Dsl, only: :macros
      @before_compile Sleeky.Entity
    end
  end

  defmacro __before_compile__(_env) do
    entity = entity(__CALLER__.module)
    generator = if entity.virtual?, do: Virtual, else: Ecto

    entity
    |> with_primary_key()
    |> with_timestamps()
    |> generator.ast()
  end

  @timestamps [
    [name: :inserted_at, kind: :datetime, implied?: true],
    [name: :updated_at, kind: :datetime, implied?: true]
  ]

  defp with_timestamps(entity) do
    Enum.reduce(@timestamps, entity, fn attr, e ->
      attr
      |> Keyword.put(:entity, entity)
      |> Attribute.new()
      |> add_to(:attributes, e)
    end)
  end

  defp with_primary_key(entity) do
    pk =
      case Enum.find(entity.attributes, & &1.primary_key?) do
        nil ->
          PrimaryKey.default()

        attr ->
          PrimaryKey.for_attribute(attr)
      end

    Map.put(entity, :primary_key, pk)
  end
end

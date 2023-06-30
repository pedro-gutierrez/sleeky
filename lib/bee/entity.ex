defmodule Bee.Entity do
  alias Bee.Entity.Attribute
  alias Bee.Entity.Ecto
  alias Bee.Entity.Virtual
  import Bee.Inspector

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
    actions: [],
    attributes: [],
    breadcrumbs: true,
    parents: [],
    children: [],
    keys: [],
    preloads: [],
    virtual?: false
  ]

  @implied_attributes [
    [name: :id, kind: :id],
    [name: :inserted_at, kind: :datetime],
    [name: :updated_at, kind: :datetime]
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

  defmacro __using__(opts) do
    module = __CALLER__.module

    entity = new(module)

    breadcrumbs = Keyword.get(opts, :breadcrumbs, true)

    entity =
      Enum.reduce(@implied_attributes, entity, fn attr, e ->
        attr
        |> Keyword.put(:entity, entity)
        |> Attribute.new()
        |> add_to(:attributes, e)
      end)
      |> Map.put(:breadcrumbs, breadcrumbs)

    Module.register_attribute(module, :entity, persist: true, accumulate: false)
    Module.put_attribute(module, :entity, entity)

    quote do
      import Bee.Entity.Dsl, only: :macros
      @before_compile Bee.Entity

      def breadcrumbs?, do: unquote(breadcrumbs)
    end
  end

  defmacro __before_compile__(_env) do
    entity = entity(__CALLER__.module)
    generator = if entity.virtual?, do: Virtual, else: Ecto

    entity
    |> with_display()
    |> generator.ast()
  end

  defp with_display(entity) do
    if !field(:display, entity) do
      case Enum.reject(entity.attributes, & &1.implied) do
        [first | _] ->
          [
            name: :display,
            kind: :string,
            entity: entity,
            computed: true,
            using: Bee.Entity.Ecto.Display.module(entity),
            plugin: {Bee.Entity.Ecto.Display, [first.name]}
          ]
          |> Attribute.new()
          |> add_to(:attributes, entity)

        _ ->
          raise "entity #{inspect(entity.module)} has no attributes to display"
      end
    else
      entity
    end
  end
end

defmodule Sleeky.Model.Parser do
  @moduledoc false
  @behaviour Diesel.Parser
  alias Sleeky.Model
  alias Sleeky.Model.Attribute
  alias Sleeky.Model.Key
  alias Sleeky.Model.Relation
  import Sleeky.Naming

  @impl true
  def parse(caller_mod, definition), do: parse(definition, caller_mod, %Model{})

  def parse({:model, attrs, children}, mod, acc) do
    children
    |> parse(mod, acc)
    |> with_model(mod, attrs)
  end

  def parse({:attribute, attrs, _}, _mod, acc) do
    attr_name = Keyword.fetch!(attrs, :name)
    kind = Keyword.fetch!(attrs, :kind)

    storage =
      case kind do
        :id -> :binary_id
        :timestamp -> :utc_datetime
        kind -> kind
      end

    attr = %Attribute{
      name: attr_name,
      column_name: attr_name,
      kind: kind,
      storage: storage,
      primary_key?: Keyword.get(attrs, :primary_key, false)
    }

    %{acc | attributes: Enum.reverse([attr | acc.attributes])}
  end

  def parse({:has_many, [], [name]}, _mod, acc) do
    rel = %Relation{
      name: name,
      kind: :has_many
    }

    %{acc | relations: Enum.reverse([rel | acc.relations])}
  end

  def parse({:belongs_to, [], [module]}, model, acc) do
    ensure_same_context!(model, module, :belongs_to)

    name = name(module)
    column_name = String.to_atom("#{name}_id")

    inverse = %Relation{
      name: plural(model),
      kind: :child,
      target: %Model{
        name: name(model),
        table_name: table_name(model),
        module: model,
        context: context(model)
      }
    }

    rel = %Relation{
      name: name,
      kind: :parent,
      model: model,
      inverse: inverse,
      column_name: column_name,
      storage: module.primary_key().storage,
      target: %Model{
        name: name,
        module: module,
        context: context(module),
        table_name: module.table_name()
      }
    }

    %{acc | relations: Enum.reverse([rel | acc.relations])}
  end

  def parse({:key, opts, []}, model, acc) do
    unique = Keyword.get(opts, :unique, false)
    field_names = Keyword.fetch!(opts, :fields)

    fields = acc.attributes ++ acc.relations

    fields =
      Enum.map(field_names, fn name ->
        with nil <- Enum.find(fields, &(&1.name == name)) do
          raise "Key is referencing unknown field #{inspect(name)} in model #{inspect(model)}"
        end
      end)

    key = %Key{fields: fields, model: model, unique?: unique}
    keys = Enum.reverse([key | acc.keys])

    %{acc | keys: keys}
  end

  def parse(tags, mod, acc) when is_list(tags) do
    Enum.reduce(tags, acc, fn tag, acc ->
      parse(tag, mod, acc)
    end)
  end

  def with_model(acc, model, attrs) do
    {primary_key, acc} =
      case Enum.find(acc.attributes, & &1.primary_key?) do
        nil ->
          primary_key = %Attribute{
            name: :id,
            kind: :id,
            storage: :binary_id,
            column_name: :id,
            primary_key?: true
          }

          {primary_key, %{acc | attributes: [primary_key | acc.attributes]}}

        primary_key ->
          {primary_key, acc}
      end

    plural = plural(model)

    %{
      acc
      | context: context(model),
        name: name(model),
        plural: plural,
        module: model,
        table_name: table_name(model),
        primary_key: primary_key,
        virtual?: Keyword.get(attrs, :virtual, false)
    }
  end

  def context(model) do
    model
    |> Module.split()
    |> Enum.reverse()
    |> tl()
    |> Enum.reverse()
    |> Module.concat()
  end

  defp table_name(model), do: plural(model)

  defp ensure_same_context!(from, to, kind) do
    from_context = context(from)
    to_context = context(to)

    if from_context != to_context do
      raise "Invalid relation of kind #{inspect(kind)} from #{inspect(from)} to
#{inspect(to)}. Both models must be in the same context."
    end
  end
end

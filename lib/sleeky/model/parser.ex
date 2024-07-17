defmodule Sleeky.Model.Parser do
  @moduledoc false

  @behaviour Diesel.Parser

  alias Sleeky.Model
  alias Sleeky.Model.Attribute
  alias Sleeky.Model.Key
  alias Sleeky.Model.Relation
  alias Sleeky.Model.Action
  alias Sleeky.Model.Policy
  import Sleeky.Naming

  @impl true
  def parse({:model, attrs, definition}, opts) do
    opts
    |> Keyword.fetch!(:caller_module)
    |> model(attrs)
    |> with_attributes(definition)
    |> with_parents(definition)
    |> with_children(definition)
    |> with_keys(definition)
    |> with_actions(definition)
    |> with_primary_key()
  end

  defp model(caller, attrs) do
    context = context(caller)

    %Model{
      context: context,
      repo: repo(context),
      name: name(caller),
      plural: plural(caller),
      module: caller,
      table_name: table_name(caller),
      virtual?: Keyword.get(attrs, :virtual, false)
    }
  end

  defp with_attributes(model, definition) do
    attrs =
      for {:attribute, opts, _} <- definition do
        attr_name = Keyword.fetch!(opts, :name)
        kind = Keyword.fetch!(opts, :kind)
        storage = storage(kind)
        required = Keyword.get(opts, :required, true)

        ensure_valid_field_name!(model, attr_name)

        %Attribute{
          name: attr_name,
          column_name: attr_name,
          kind: kind,
          storage: storage,
          aliases: [attr_name],
          required?: required
        }
      end

    %{model | attributes: attrs}
  end

  @reserved_field_names [:id]

  defp ensure_valid_field_name!(model, name) do
    if name in @reserved_field_names do
      raise "field #{inspect(name)} in model #{inspect(model.module)} is using a reserved name
        (#{inspect(@reserved_field_names)})"
    end
  end

  defp with_parents(model, definition) do
    model_module = model.module

    rels =
      for {:belongs_to, [], [parent_module]} <- definition do
        ensure_same_context!(model_module, parent_module, :belongs_to)

        name = name(parent_module)
        table_name = table_name(parent_module)
        column_name = column_name(parent_module)
        storage = storage(:id)

        rel = %Relation{
          name: name,
          kind: :parent,
          model: model.module,
          inverse: %Relation{
            name: model.plural,
            model: parent_module,
            kind: :child,
            target: summary_model(model)
          },
          table_name: table_name,
          column_name: column_name,
          storage: storage,
          target: summary_model(parent_module),
          aliases: [name]
        }

        %{rel | foreign_key_name: foreign_key_name(rel)}
      end

    %{model | relations: rels}
  end

  defp with_children(model, definition) do
    rels =
      for {:has_many, [], [child_module]} <- definition do
        ensure_same_context!(model.module, child_module, :has_many)

        name = plural(child_module)

        inverse = %Relation{
          name: name(model.module),
          model: child_module,
          kind: :parent,
          target: summary_model(model),
          table_name: table_name(child_module),
          column_name: column_name(model.module)
        }

        inverse = %{inverse | foreign_key_name: foreign_key_name(inverse)}

        %Relation{
          name: name,
          aliases: [name],
          kind: :child,
          model: model.module,
          inverse: inverse,
          target: summary_model(child_module)
        }
      end

    %{model | relations: model.relations ++ rels}
  end

  defp with_keys(model, definition) do
    keys =
      for {:key, opts, _} <- definition do
        unique = Keyword.get(opts, :unique, false)
        field_names = Keyword.fetch!(opts, :fields)
        fields = model.attributes ++ model.relations

        fields =
          Enum.map(field_names, fn name ->
            with nil <- Enum.find(fields, &(&1.name == name)) do
              known_field_names = Enum.map(fields, & &1.name)

              raise "Key in model #{inspect(model.module)} is referencing unknown field
                #{inspect(name)}. Known fields: #{inspect(known_field_names)}"
            end
          end)

        %Key{fields: fields, model: model.module, unique?: unique}
      end

    %{model | keys: keys}
  end

  defp with_actions(model, definition) do
    actions =
      for {:action, opts, policies} <- definition do
        name = Keyword.fetch!(opts, :name)

        policies =
          for {policy, opts, _} <- policies do
            role = Keyword.fetch!(opts, :role)
            scope = Keyword.get(opts, :scope)

            %Policy{role: role, scope: scope, policy: policy}
          end

        policies =
          Enum.reduce(policies, %{}, fn policy, acc ->
            Map.put(acc, policy.role, policy)
          end)

        kind = Keyword.get(opts, :kind, name)

        %Action{
          name: name,
          kind: kind,
          policies: policies
        }
      end

    %{model | actions: actions}
  end

  defp storage(:id), do: :binary_id
  defp storage(:timestamp), do: :utc_datetime
  defp storage(kind), do: kind

  @primary_key %Attribute{
    name: :id,
    kind: :id,
    storage: :binary_id,
    column_name: :id,
    primary_key?: true,
    mutable?: false
  }

  defp with_primary_key(model) do
    %{model | primary_key: @primary_key, attributes: [@primary_key | model.attributes]}
  end

  defp ensure_same_context!(from, to, kind) do
    from_context = context(from)
    to_context = context(to)

    if from_context != to_context do
      raise "invalid relation of kind #{inspect(kind)} from #{inspect(from)} (in context #{inspect(from_context)}) to #{inspect(to)} (in context #{inspect(to_context)}). Both models must be in the same context."
    end
  end

  defp summary_model(%Model{} = model), do: summary_model(model.module)

  defp summary_model(module) do
    %{
      module: module,
      name: name(module),
      table_name: table_name(module),
      plural: plural(module),
      context: context(module)
    }
  end
end

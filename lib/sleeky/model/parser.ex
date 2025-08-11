defmodule Sleeky.Model.Parser do
  @moduledoc false

  @behaviour Diesel.Parser

  alias Sleeky.Model
  alias Sleeky.Model.Attribute
  alias Sleeky.Model.Key
  alias Sleeky.Model.Relation
  alias Sleeky.Model.Action
  alias Sleeky.Model.OnConflict
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
    |> with_timestamps()
  end

  defp model(caller, attrs) do
    feature = feature(caller)

    %Model{
      feature: feature,
      repo: repo(feature),
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
        ecto_type = ecto_type(kind)
        storage = storage(kind)
        required = Keyword.get(opts, :required, true)
        allowed_values = Keyword.get(opts, :in, [])
        default = Keyword.get(opts, :default)

        ensure_valid_field_name!(model, attr_name)

        %Attribute{
          name: attr_name,
          column_name: attr_name,
          kind: kind,
          ecto_type: ecto_type,
          storage: storage,
          aliases: [attr_name],
          required?: required,
          in: allowed_values,
          default: default
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
    rels =
      for opts <- children_tags(definition, :belongs_to) do
        parent_module = Keyword.fetch!(opts, :name)
        ensure_same_feature!(model.module, parent_module, :belongs_to)
        required = Keyword.get(opts, :required, true)

        name = name(parent_module)
        table_name = table_name(parent_module)
        column_name = column_name(parent_module)
        storage = storage(:id)

        rel = %Relation{
          name: name,
          kind: :parent,
          model: model.module,
          required?: required,
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

        foreign_key_name = String.to_atom("#{model.table_name}_#{column_name}_fkey")

        %{rel | foreign_key_name: foreign_key_name}
      end

    %{model | relations: rels}
  end

  defp with_children(model, definition) do
    rels =
      for {:has_many, [], [child_module]} <- definition do
        ensure_same_feature!(model.module, child_module, :has_many)

        name = plural(child_module)

        inverse = %Relation{
          name: name(model.module),
          model: child_module,
          kind: :parent,
          target: summary_model(model),
          table_name: table_name(child_module),
          column_name: column_name(model.module)
        }

        foreign_key_name = String.to_atom("#{inverse.table_name}_#{inverse.column_name}_fkey")

        inverse = %{inverse | foreign_key_name: foreign_key_name}

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

  defp fields!(model, field_names) do
    fields = model.attributes ++ model.relations

    Enum.map(field_names, fn name ->
      with nil <- Enum.find(fields, &(&1.name == name)) do
        known_field_names = Enum.map(fields, & &1.name)

        raise "Key in model #{inspect(model.module)} is referencing unknown field
          #{inspect(name)}. Known fields: #{inspect(known_field_names)}"
      end
    end)
  end

  defp with_keys(model, definition) do
    keys =
      for {:key, opts, _} <- definition do
        unique = Keyword.get(opts, :unique, false)
        field_names = Keyword.fetch!(opts, :fields)
        fields = fields!(model, field_names)
        name = field_names |> Enum.join("_") |> String.to_atom()

        %Key{fields: fields, model: model.module, unique?: unique, name: name}
      end

    unique_keys =
      for {:unique, [fields: field_names], opts} <- definition do
        fields = fields!(model, field_names)
        name = field_names |> Enum.join("_") |> String.to_atom()

        on_conflict =
          with %OnConflict{} = on_conflict <- on_conflict(opts) do
            %{on_conflict | fields: fields}
          end

        %Key{
          fields: fields,
          model: model.module,
          unique?: true,
          name: name,
          on_conflict: on_conflict
        }
      end

    %{model | keys: Enum.uniq(keys ++ unique_keys)}
  end

  defp with_actions(model, definition) do
    actions =
      for {:action, opts, children} <- definition do
        name = Keyword.fetch!(opts, :name)

        policies =
          children
          |> Enum.map(&action_policy/1)
          |> Enum.reject(&is_nil/1)
          |> Enum.reduce(%{}, fn policy, acc ->
            Map.put(acc, policy.role, policy)
          end)

        tasks =
          children
          |> Enum.map(&action_tasks/1)
          |> List.flatten()
          |> Enum.reject(&is_nil/1)

        kind = Keyword.get(opts, :kind, name)

        %Action{
          name: name,
          kind: kind,
          policies: policies,
          tasks: tasks
        }
      end

    %{model | actions: actions}
  end

  defp action_policy({:role, [name: nil, scope: nil], [name]}) do
    %Policy{role: name, policy: :allow}
  end

  defp action_policy({:role, [name: role, scope: nil], [scope]}) do
    %Policy{role: role, scope: scope(scope), policy: :allow}
  end

  defp action_policy({:role, [name: role, scope: scope], []}) do
    %Policy{role: role, scope: scope(scope), policy: :allow}
  end

  defp action_policy(_), do: nil

  defp action_tasks({:task, [name: nil, if: nil], [module]}),
    do: %Sleeky.Model.Task{module: module}

  defp action_tasks({:task, [name: module, if: nil], _}), do: %Sleeky.Model.Task{module: module}

  defp action_tasks({:task, [name: module, if: condition], _}),
    do: %Sleeky.Model.Task{module: module, if: condition}

  defp action_tasks({:on, conditions, modules}) do
    for module <- modules do
      %Sleeky.Model.Task{module: module, if: conditions}
    end
  end

  defp action_tasks(_), do: nil

  defp on_conflict([{:on_conflict, opts, _}]) do
    strategy = Keyword.fetch!(opts, :name)
    except = Keyword.get(opts, :except, [:id])

    %OnConflict{
      strategy: strategy,
      except: except
    }
  end

  defp on_conflict(_), do: nil

  defp scope(name) when is_atom(name), do: name
  defp scope(scopes) when is_list(scopes), do: Enum.map(scopes, &scope/1)
  defp scope({:scope, [], [scope]}), do: scope(scope)
  defp scope({:one, [], scopes}), do: {:one, scope(scopes)}
  defp scope({:all, [], scopes}), do: {:all, scope(scopes)}

  defp storage(:id), do: :binary_id
  defp storage(:datetime), do: :utc_datetime
  defp storage(:text), do: :text
  defp storage(kind), do: kind

  defp ecto_type(:id), do: :binary_id
  defp ecto_type(:datetime), do: :utc_datetime
  defp ecto_type(:text), do: :string
  defp ecto_type(kind), do: kind

  @primary_key %Attribute{
    name: :id,
    kind: :id,
    ecto_type: :binary_id,
    storage: :binary_id,
    column_name: :id,
    primary_key?: true,
    mutable?: false
  }

  @inserted_at %Attribute{
    name: :inserted_at,
    kind: :datetime,
    ecto_type: :utc_datetime,
    storage: :utc_datetime,
    column_name: :inserted_at,
    primary_key?: false,
    mutable?: false
  }

  @updated_at %Attribute{
    name: :updated_at,
    kind: :datetime,
    ecto_type: :utc_datetime,
    storage: :utc_datetime,
    column_name: :updated_at,
    primary_key?: false,
    mutable?: true
  }

  defp with_primary_key(model) do
    %{model | primary_key: @primary_key, attributes: [@primary_key | model.attributes]}
  end

  defp with_timestamps(model) do
    attributes = model.attributes ++ [@inserted_at, @updated_at]

    %{model | attributes: attributes}
  end

  defp ensure_same_feature!(from, to, kind) do
    from_feature = feature(from)
    to_feature = feature(to)

    if from_feature != to_feature do
      raise "invalid relation of kind #{inspect(kind)} from #{inspect(from)} (in feature#{inspect(from_feature)}) to #{inspect(to)} (in feature #{inspect(to_feature)}). Both models must be in the same feature."
    end
  end

  defp summary_model(%Model{} = model), do: summary_model(model.module)

  defp summary_model(module) do
    %{
      module: module,
      name: name(module),
      table_name: table_name(module),
      plural: plural(module),
      feature: feature(module)
    }
  end

  defp children_tags(definition, tag_name) do
    definition
    |> Enum.map(fn
      {^tag_name, [], [parent_module]} ->
        [name: parent_module, required: true]

      {^tag_name, opts, _} ->
        opts

      _ ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end
end

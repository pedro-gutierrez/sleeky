defmodule Sleeky.Context.Ast do
  @moduledoc """
  Context specific ast helpers
  """

  import Sleeky.Naming

  @doc """
  Returns a list of pattern matched variables for each one of the parents of the given entity
  """
  def function_parent_args(entity) do
    for rel <- entity.parents() do
      quote do
        %unquote(rel.target.module){} = unquote(var(rel.name))
      end
    end
  end

  @doc """
  Populate a context map with the values for the parent entities of a given entity
  """
  def context_with_parents(entity) do
    context = var(:context)

    for rel <- entity.parents() do
      var = var(rel.name)

      quote do
        unquote(context) <- Map.put(unquote(context), unquote(rel.name), unquote(var))
      end
    end
  end

  @doc """
  Populate a context map with the params given to an action
  """
  def context_with_params do
    context = var(:context)
    attrs = var(:attrs)

    quote do
      unquote(context) <- Map.merge(unquote(attrs), unquote(context))
    end
  end

  @doc """
  Populate a context map with a given entity
  """
  def context_with_entity(entity) do
    entity_name = entity.name()
    context = var(:context)
    entity_var = var(entity_name)

    quote do
      unquote(context) <- Map.put(unquote(context), unquote(entity_name), unquote(entity_var))
    end
  end

  @doc """
  Populates the map of attributes, with the ids from required parents
  """
  def attrs_with_required_parents(entity) do
    attrs = var(:attrs)

    for %{required?: true} = rel <- entity.parents() do
      column = rel.column_name
      var = var(rel.name)

      quote do
        unquote(attrs) <- Map.put(unquote(attrs), unquote(column), unquote(attrs).unquote(var).id)
      end
    end
  end

  @doc """
  Populates the map of attributes, with the ids from optional parents
  """
  def attrs_with_optional_parents(entity) do
    attrs = var(:attrs)

    for %{required?: false} = rel <- entity.parents() do
      column = rel.column_name
      var = var(rel.name)

      quote do
        unquote(attrs) <- Map.put(unquote(attrs), unquote(column), maybe_id(unquote(var)))
      end
    end
  end

  @doc """
  Collects computeed attributes values and sets them into the map of attributes
  """
  def attrs_with_computed_attributes(entity) do
    attrs = var(:attrs)
    context = var(:context)

    for %{computed?: true, using: mod} = attr <- entity.attributes() do
      quote do
        unquote(attrs) <-
          compute_attribute(unquote(attrs), unquote(attr.name), unquote(mod), unquote(context))
      end
    end
  end

  @doc """
  Sets the map of attrs into the context, for authorization purposes
  """
  def context_with_args do
    context = var(:context)
    attrs = var(:attrs)

    quote do
      unquote(context) <- Map.put(unquote(context), :args, unquote(attrs))
    end
  end

  def allowed?(entity, action) do
    action_name = action.name
    entity_name = entity.name()
    context = var(:context)

    quote do
      :ok <- allow(unquote(entity_name), unquote(action_name), unquote(context))
    end
  end

  @doc """
  Generats the code that fetches the entity and sets its as a variable inside a with clause
  """
  def fetch_entity(entity) do
    entity_name = entity.name()
    entity_var = var(entity_name)
    id = var(:id)
    context = var(:context)

    quote do
      {:ok, unquote(entity_var)} <- unquote(entity).fetch(unquote(id), unquote(context))
    end
  end
end

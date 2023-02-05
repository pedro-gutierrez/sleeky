defmodule Bee.Rest.Handlers.Default do
  @moduledoc false

  alias Bee.Entity.Action
  alias Bee.Entity.Attribute

  import Bee.Inspector
  import Bee.Rest.Handlers.Helpers

  def handlers(entity, rest) do
    for action <- entity.actions do
      action_handler(rest, entity, action)
    end
  end

  def routes(entity, rest) do
    for action <- entity.actions do
      handler = module_name(rest, entity, action)
      method = http_method(action)
      path = http_path(action)

      quote do
        unquote(method)(unquote(path), to: unquote(handler))
      end
    end
  end

  def http_method(:read), do: :get
  def http_method(:list), do: :get
  def http_method(:create), do: :post
  def http_method(:update), do: :patch
  def http_method(:delete), do: :delete
  def http_method(%Action{} = action), do: http_method(action.name)

  defp http_path(%Action{} = action) do
    case action.name do
      :read -> resource_http_path(action.entity)
      :list -> collection_http_path(action.entity)
      :create -> collection_http_path(action.entity)
      :update -> resource_http_path(action.entity)
      :delete -> resource_http_path(action.entity)
    end
  end

  defp resource_http_path(entity), do: "/#{entity.plural}/:id"
  defp collection_http_path(entity), do: "/#{entity.plural}"

  defp action_handler(rest, entity, %Action{name: :list} = action) do
    conn = var(:conn)

    preconditions = [
      pagination_args(),
      query_arg(),
      api_call(entity, action)
    ]

    body = [
      quote do
        def handle(unquote(conn), _opts) do
          with unquote_splicing(flatten(preconditions)) do
            send_json(unquote(conn), items)
          else
            {:error, reason} -> send_error(unquote(conn), reason)
          end
        end
      end
    ]

    handler(rest, entity, action, body)
  end

  defp action_handler(rest, entity, %Action{name: :create} = action) do
    conn = var(:conn)
    args = var(:args)

    preconditions = [
      attribute_args(entity, action),
      parent_args(entity, action),
      id_arg(),
      api_call(entity, action)
    ]

    body =
      quote do
        def handle(unquote(conn), _opts) do
          unquote(args) = %{}

          with unquote_splicing(flatten(preconditions)) do
            send_json(unquote(conn), item, 201)
          else
            {:error, reason} -> send_error(unquote(conn), reason)
          end
        end
      end

    handler(rest, entity, action, body)
  end

  defp action_handler(rest, entity, %Action{name: :update} = action) do
    conn = var(:conn)
    args = var(:args)

    preconditions = [
      required_id_arg(),
      api_get(entity),
      attribute_args(entity, action),
      parent_args(entity, action),
      api_call(entity, action)
    ]

    body = [
      quote do
        def handle(unquote(conn), _opts) do
          unquote(args) = %{}

          with unquote_splicing(flatten(preconditions)) do
            send_json(unquote(conn), item, 200)
          else
            {:error, reason} -> send_error(unquote(conn), reason)
          end
        end
      end
    ]

    handler(rest, entity, action, body)
  end

  defp action_handler(rest, entity, %Action{name: :read} = action) do
    conn = var(:conn)
    args = var(:args)

    preconditions = [
      required_id_arg(),
      api_call(entity, action)
    ]

    body = [
      quote do
        def handle(unquote(conn), _opts) do
          unquote(args) = %{}

          with unquote_splicing(flatten(preconditions)) do
            send_json(unquote(conn), item)
          else
            {:error, reason} -> send_error(unquote(conn), reason)
          end
        end
      end
    ]

    handler(rest, entity, action, body)
  end

  defp action_handler(rest, entity, %Action{name: :delete} = action) do
    conn = var(:conn)
    args = var(:args)

    preconditions = [
      required_id_arg(),
      api_get(entity),
      api_call(entity, action)
    ]

    body = [
      quote do
        def handle(unquote(conn), _opts) do
          unquote(args) = %{}

          with unquote_splicing(flatten(preconditions)) do
            send_json(unquote(conn), %{}, 204)
          else
            {:error, reason} -> send_error(unquote(conn), reason)
          end
        end
      end
    ]

    handler(rest, entity, action, body)
  end

  defp attribute_args(entity, action) do
    [
      required_attribute_args(entity, action)
    ]
  end

  defp required_attribute_args(entity, %Action{name: :create}) do
    args = var(:args)
    conn = var(:conn)

    for %Attribute{implied: false, computed: false} = attr <- entity.attributes do
      default = :invalid

      quote do
        {:ok, unquote(args)} <-
          unquote(conn)
          |> cast_param(unquote(to_string(attr.name)), unquote(attr.kind), unquote(default))
          |> as(unquote(attr.name), unquote(args))
      end
    end
  end

  defp required_attribute_args(entity, %Action{name: :update}) do
    args = var(:args)
    conn = var(:conn)

    for %Attribute{implied: false, computed: false} = attr <- entity.attributes do
      quote do
        {:ok, unquote(args)} <-
          unquote(conn)
          |> cast_param(
            unquote(to_string(attr.name)),
            unquote(attr.kind),
            item.unquote(attr.name)
          )
          |> as(unquote(attr.name), unquote(args))
      end
    end
  end

  defp parent_args(entity, action) do
    [
      required_parent_args(entity, action)
    ]
  end

  defp required_parent_args(entity, %Action{name: :create}) do
    conn = var(:conn)

    for rel <- entity.parents do
      name = rel.name
      target_entity = rel.target.module
      var_name = var(name)
      default = :required

      [
        quote do
          {:ok, unquote(var_name)} <-
            lookup(
              unquote(conn),
              unquote(to_string(name)),
              unquote(target_entity),
              unquote(default)
            )
        end,
        quote do
          unquote(conn) <- assign(unquote(conn), unquote(name), unquote(var_name))
        end
      ]
    end
  end

  defp required_parent_args(entity, %Action{name: :update}) do
    conn = var(:conn)

    for rel <- entity.parents do
      name = rel.name
      target_entity = rel.target.module
      var_name = var(name)

      [
        quote do
          {:ok, unquote(var_name)} <-
            lookup(
              unquote(conn),
              unquote(to_string(name)),
              unquote(target_entity),
              {:relation, unquote(entity), item, unquote(name)}
            )
        end,
        quote do
          unquote(conn) <- assign(unquote(conn), unquote(name), unquote(var_name))
        end
      ]
    end
  end

  defp id_arg do
    conn = var(:conn)
    args = var(:args)

    quote do
      {:ok, unquote(args)} <-
        unquote(conn) |> cast_param("id", :id, :continue) |> as(:id, unquote(args))
    end
  end

  defp api_get(entity) do
    args = var(:args)

    quote do
      {:ok, item} <- unquote(entity).get(unquote(args).id)
    end
  end

  defp api_call(entity, %Action{name: :create}) do
    conn = var(:conn)
    args = var(:args)
    parent_var_names = entity.parents() |> names() |> vars()

    quote do
      {:ok, item} <-
        unquote(entity).create(
          unquote_splicing(parent_var_names),
          unquote(args),
          unquote(conn).assigns
        )
    end
  end

  defp api_call(entity, %Action{name: :update}) do
    conn = var(:conn)
    args = var(:args)
    parent_var_names = entity.parents() |> names() |> vars()

    quote do
      {:ok, item} <-
        unquote(entity).update(
          unquote_splicing(parent_var_names),
          item,
          unquote(args),
          unquote(conn).assigns
        )
    end
  end

  defp api_call(entity, %Action{name: :list}) do
    conn = var(:conn)

    quote do
      {:ok, items} <- unquote(entity).list(unquote(conn).assigns)
    end
  end

  defp api_call(entity, %Action{name: :read}) do
    conn = var(:conn)
    args = var(:args)

    quote do
      {:ok, item} <- unquote(entity).read(unquote(args).id, unquote(conn).assigns)
    end
  end

  defp api_call(entity, %Action{name: :delete}) do
    conn = var(:conn)

    quote do
      {:ok, _} <- unquote(entity).delete(item, unquote(conn).assigns)
    end
  end
end

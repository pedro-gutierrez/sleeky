defmodule Bee.Rest.Handlers do
  @moduledoc false

  import Bee.Inspector

  alias Bee.Entity.Attribute
  alias Bee.Entity.Action

  def module_name(rest, entity, action) do
    module([rest, Handler, entity.name(), action.name])
  end

  def ast(rest, schema) do
    schema.entities()
    |> Enum.map(&handlers(rest, &1))
    |> flatten()
  end

  defp handlers(rest, entity) do
    [
      standard_handlers(rest, entity)
    ]
  end

  defp standard_handlers(rest, entity) do
    for action <- entity.actions do
      action_handler(rest, entity, action)
    end
  end

  defp action_handler(rest, entity, %Action{name: :create} = action) do
    preconditions = [
      attribute_args(entity),
      parent_args(entity, action),
      id_arg(),
      api_call(entity, action)
    ]

    body =
      quote do
        def handle(conn, _opts) do
          args = %{}

          with unquote_splicing(flatten(preconditions)) do
            send_json(conn, item, 201)
          else
            {:error, reason} -> send_error(conn, reason)
          end
        end
      end

    handler(rest, entity, action, body) |> print()
  end

  defp action_handler(rest, entity, %Action{name: :list} = action) do
    preconditions = [
      pagination_args(),
      api_call(entity, action)
    ]

    body = [
      quote do
        def handle(conn, _opts) do
          with unquote_splicing(flatten(preconditions)) do
            send_json(conn, items)
          else
            {:error, reason} -> send_error(conn, reason)
          end
        end
      end
    ]

    handler(rest, entity, action, body)
  end

  defp action_handler(rest, entity, %Action{name: :update} = action) do
    body = [
      quote do
        def handle(conn, _opts) do
          send_json(conn, %{}, 200)
        end
      end
    ]

    handler(rest, entity, action, body)
  end

  defp action_handler(rest, entity, %Action{name: :read} = action) do
    body = [
      quote do
        def handle(conn, _opts) do
          send_json(conn, %{}, 200)
        end
      end
    ]

    handler(rest, entity, action, body)
  end

  defp action_handler(rest, entity, %Action{name: :delete} = action) do
    body = [
      quote do
        def handle(conn, _opts) do
          send_json(conn, %{}, 204)
        end
      end
    ]

    handler(rest, entity, action, body)
  end

  defp handler(rest, entity, action, body) when is_list(body) do
    module_name = module_name(rest, entity, action)
    helper = module(rest, RouterHelper)

    quote do
      defmodule unquote(module_name) do
        use Plug.Builder
        import unquote(helper)

        plug(:handle)

        unquote_splicing(body)
      end
    end
  end

  defp handler(rest, entity, action, body) do
    handler(rest, entity, action, [body])
  end

  defp pagination_args do
    quote do
      {:ok, conn} <- with_pagination(conn)
    end
  end

  defp attribute_args(entity) do
    [
      required_attribute_args(entity)
    ]
  end

  defp required_attribute_args(entity) do
    for %Attribute{implied: false, computed: false} = attr <- entity.attributes do
      default = :invalid

      quote do
        {:ok, args} <-
          conn
          |> cast_param(unquote(to_string(attr.name)), unquote(attr.kind), unquote(default))
          |> as(unquote(attr.name), args)
      end
    end
  end

  defp parent_args(entity, action) do
    [
      required_parent_args(entity, action.name)
    ]
  end

  defp required_parent_args(entity, :create) do
    for rel <- entity.parents do
      name = rel.name
      target_entity = rel.target.module
      var_name = var(name)
      default = :required

      [
        quote do
          {:ok, unquote(var_name)} <-
            lookup(
              conn,
              unquote(to_string(name)),
              unquote(target_entity),
              unquote(default)
            )
        end,
        quote do
          conn <- assign(conn, unquote(name), unquote(var_name))
        end
      ]
    end
  end

  defp id_arg do
    quote do
      {:ok, args} <-
        conn |> cast_param("id", :id, :continue) |> as(:id, args)
    end
  end

  defp api_call(entity, %Action{name: :create}) do
    parent_var_names = entity.parents() |> names() |> vars()

    quote do
      {:ok, item} <-
        unquote(entity).create(unquote_splicing(parent_var_names), args, conn.assigns)
    end
  end

  defp api_call(entity, %Action{name: :list}) do
    quote do
      {:ok, items} <- unquote(entity).list(conn.assigns)
    end
  end
end

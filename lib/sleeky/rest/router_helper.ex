defmodule Sleeky.Rest.RouterHelper do
  @moduledoc false

  def ast(rest, _schema) do
    helper_module = Module.concat(rest, RouterHelper)

    quote do
      defmodule unquote(helper_module) do
        import Plug.Conn
        require Logger
        @json "application/json"

        def send_json(conn, body, status \\ 200) do
          if status >= 500, do: Logger.error("application error", reason: inspect(body))

          conn
          |> put_resp_content_type(@json)
          |> send_resp(status, Jason.encode!(body))
        end

        def send_error(conn, %Ecto.Changeset{errors: errors}) do
          reason =
            Enum.map(errors, fn {field, {message, _}} ->
              %{field: field, detail: message}
            end)

          send_error(conn, reason)
        end

        def send_error(conn, reason) do
          send_json(conn, %{reason: reason(reason)}, status(reason))
        end

        def cast_param(conn, name, kind, default \\ :invalid) do
          value = conn.params[name]

          cast(value, kind, default, name)
        end

        def lookup(conn, param, api, :required) do
          with {:ok, id} <- cast_param(conn, param, :id) do
            api.get(id)
          end
        end

        def lookup(conn, param, api, :optional) do
          lookup_or_default(conn, param, api, fn -> nil end)
        end

        def lookup(conn, param, api, {:relation, api2, item, rel}) do
          lookup_or_default(conn, param, api, fn ->
            api2.relation(item, rel)
          end)
        end

        defp lookup_or_default(conn, param, api, default_fn) do
          case conn.params[param] do
            nil ->
              {:ok, default_fn.()}

            "" ->
              {:ok, default_fn.()}

            value ->
              with {:ok, id} <- cast(value, :id, param) do
                api.get(id)
              end
          end
        end

        def lookup_relation(api, entity, relation) do
          entity
          |> api.relation(relation)
          |> maybe_error(:not_found)
        end

        def lookup_context(context, path) do
          context
          |> get_in(path)
          |> maybe_error(:missing_context)
        end

        defp maybe_error(nil, reason), do: {:error, reason}
        defp maybe_error(value, _), do: {:ok, value}

        def with_pagination(conn) do
          with {:ok, offset} <- cast_param(conn, "offset", :integer, 0),
               {:ok, limit} <- cast_param(conn, "limit", :integer, 20),
               {:ok, sort_by} <- cast_param(conn, "sort_by", :string, nil),
               {:ok, sort_direction} <- cast_param(conn, "sort_direction", :atom, :asc) do
            {:ok,
             conn
             |> assign(:offset, offset)
             |> assign(:limit, limit)
             |> assign(:sort_by, sort_by)
             |> assign(:sort_direction, sort_direction)}
          end
        end

        def with_query(conn) do
          with {:ok, query} <- cast_param(conn, "q", :string, nil) do
            {:ok, assign(conn, :q, query)}
          end
        end

        defp cast(nil, _, :invalid, field), do: invalid(field)
        defp cast("", _, :invalid, field), do: invalid(field)
        defp cast(nil, _, :required, field), do: required(field)
        defp cast("", _, :required, field), do: required(field)
        defp cast(nil, _, :continue, _), do: {:error, :continue}
        defp cast("", _, :continue, _), do: {:error, :continue}
        defp cast(nil, _, default, _), do: {:ok, default}
        defp cast("", _, default, _), do: {:ok, default}
        defp cast(v, kind, _, field), do: cast(v, kind, field)

        defp cast(v, :id, field) do
          with :error <- Ecto.UUID.cast(v) do
            invalid(field)
          end
        end

        defp cast(v, :integer, field) do
          case Integer.parse(v) do
            {v, ""} -> {:ok, v}
            :error -> invalid(field)
          end
        end

        defp cast(v, :string, _field) when is_binary(v), do: {:ok, v}
        defp cast(v, :atom, _field) when is_binary(v), do: {:ok, String.to_existing_atom(v)}
        defp cast(json, :json, _field) when is_map(json), do: {:ok, json}

        defp cast(v, :datetime, field) do
          case DateTime.from_iso8601(v) do
            {:ok, dt, _} -> {:ok, dt}
            {:error, _} -> invalid(field)
          end
        end

        defp invalid(field), do: error(field, :invalid)
        defp required(field), do: error(field, :required)

        defp error(field, reason) do
          {:error, %{reason: reason, field: field}}
        end

        def as(result, arg, args \\ %{})
        def as({:ok, v}, arg, args), do: {:ok, Map.put(args, arg, v)}
        def as({:error, :continue}, _, args), do: {:ok, args}
        def as({:error, _} = error, _, _), do: error

        defp reason(r) when is_atom(r), do: r |> to_string() |> reason()
        defp reason(r) when is_binary(r), do: [%{detail: r}]
        defp reason(r) when is_list(r), do: r
        defp reason(r) when is_map(r), do: r

        defp status(:not_found), do: 404
        defp status(:invalid), do: 400
        defp status(:required), do: 400
        defp status(:unauthorized), do: 401
        defp status(:conflict), do: 409
        defp status([%{detail: "has already been taken"}]), do: 409
        defp status(%{reason: reason}), do: status(reason)
        defp status(_), do: 500
      end
    end
  end
end

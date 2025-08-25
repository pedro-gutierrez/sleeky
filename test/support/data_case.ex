defmodule Sleeky.DataCase do
  @moduledoc false

  defmacro __using__(opts) do
    config = Application.fetch_env!(:sleeky, Sleeky)
    repo = Keyword.fetch!(config, :repo)
    endpoint = Keyword.fetch!(config, :endpoint)
    opts = Keyword.put_new(opts, :async, false)

    quote do
      @repo unquote(repo)
      @endpoint unquote(endpoint)
      @router @endpoint.router()

      use ExUnit.Case, unquote(opts)
      use Oban.Testing, repo: @repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Sleeky.ErrorsHelper
      import Sleeky.SqlHelper
      import Sleeky.Fixtures
      import Plug.Test
      import Plug.Conn

      alias Ecto.Adapters.SQL.Sandbox
      alias Ecto.Adapters.Postgres.Connection, as: SQL

      setup tags do
        Application.ensure_all_started(:sleeky)
        start_supervised!(@repo)
        start_supervised!(@endpoint)

        oban_config = Application.fetch_env!(:sleeky, Oban)
        start_supervised!({Oban, oban_config})

        pid = Sandbox.start_owner!(@repo, shared: not tags[:async])
        on_exit(fn -> Sandbox.stop_owner(pid) end)
        :ok
      end

      defp get(path, opts \\ []), do: route(:get, path, headers: headers(opts))
      defp delete(path, opts \\ []), do: route(:delete, path, headers: headers(opts))

      defp post(path, data, opts \\ []) do
        method = opts[:method] || :post
        data = Jason.encode!(data)

        route(method, path, headers: headers(opts), params: data)
      end

      defp patch(path, data, opts \\ []) do
        opts = Keyword.put(opts, :method, :patch)

        post(path, data, opts)
      end

      def test_conn(params, opts \\ []) do
        method = opts[:method] || :get
        path = opts[:path] || "/"

        conn(method, path, params)
      end

      @router_opts @router.init([])

      defp route(method, path, opts) do
        conn =
          method
          |> new_conn(path, opts)
          |> @router.call(@router_opts)
      end

      defp new_conn(method, path, opts \\ []) do
        method
        |> conn(path, opts[:params])
        |> with_req_headers(opts[:headers] || %{})
      end

      def ok!(conn) do
        assert conn.state == :sent
        assert conn.status == 200
      end

      defp json_response!(conn, status \\ 200) do
        assert_status_code(conn, status)
        assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
        Jason.decode!(conn.resp_body)
      end

      defp html_response!(conn, status \\ 200) do
        assert_status_code(conn, status)
        assert get_resp_header(conn, "content-type") == ["text/html; charset=utf-8"]
        conn.resp_body
      end

      defp assert_status_code(conn, status) do
        assert :sent == conn.state

        if status != conn.status do
          flunk("""
          Expected status code #{status} but got #{conn.status} with response body:

            #{inspect(conn.resp_body)}

          """)
        end
      end

      defp with_req_headers(conn, headers) do
        Enum.reduce(headers, conn, fn {key, value}, conn ->
          put_req_header(conn, key, value)
        end)
      end

      defp headers(opts) do
        opts
        |> Keyword.get(:headers, %{})
        |> Map.new()
        |> Map.put_new("content-type", "application/json")
        |> maybe_auth_header(opts[:token])
      end

      defp maybe_auth_header(headers, nil), do: headers

      defp maybe_auth_header(headers, token),
        do: Map.put(headers, "authorization", "Bearer " <> token)

      defp to_sql(query), do: to_sql(query, @repo)

      def assert_event_published(event) do
        assert_enqueued(worker: Sleeky.Job, args: %{event: event})
      end

      def refute_event_published(event) do
        refute_enqueued(worker: Sleeky.Job, args: %{event: event})
      end

      defp assert_job_success(count \\ 1) do
        assert_enqueued(worker: Sleeky.Job)
        assert %{success: ^count} = Oban.drain_queue(queue: :default)
      end
    end
  end
end

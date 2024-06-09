defmodule Sleeky.DataCase do
  @moduledoc false

  defmacro __using__(opts) do
    config = Application.fetch_env!(:sleeky, Sleeky)
    repo = Keyword.fetch!(config, :repo)
    endpoint = Keyword.fetch!(config, :endpoint)

    quote do
      @repo unquote(repo)
      @endpoint unquote(endpoint)
      @router @endpoint.router()

      use ExUnit.Case, unquote(opts)
      use Plug.Test

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Sleeky.Fixtures
      import Plug.Conn

      alias Ecto.Adapters.SQL.Sandbox
      alias Ecto.Adapters.Postgres.Connection, as: SQL

      setup tags do
        Application.ensure_all_started(:sleeky)
        start_supervised!(@repo)
        start_supervised!(@endpoint)

        pid = Sandbox.start_owner!(@repo, shared: not tags[:async])
        on_exit(fn -> Sandbox.stop_owner(pid) end)
        :ok
      end

      @doc """
      A helper that transforms changeset errors into a map of messages.

          assert {:error, changeset} = Accounts.create_user(%{password: "short"})
          assert "password is too short" in errors_on(changeset).password
          assert %{password: ["password is too short"]} = errors_on(changeset)

      """
      def errors_on(changeset) do
        Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
          Regex.replace(~r"%{(\w+)}", message, fn _, key ->
            opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
          end)
        end)
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
          |> conn(path, opts[:params])
          |> with_req_headers(opts[:headers] || %{})
          |> @router.call(@router_opts)
      end

      def ok!(conn) do
        assert conn.state == :sent
        assert conn.status == 200
      end

      defp json_response!(conn, status \\ 200) do
        assert :sent == conn.state
        assert status == conn.status
        Jason.decode!(conn.resp_body)
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
        |> Map.put_new("content-type", "application/vnd.api+json")
        |> maybe_auth_header(opts[:token])
      end

      defp maybe_auth_header(headers, nil), do: headers

      defp maybe_auth_header(headers, token),
        do: Map.put(headers, "authorization", "Bearer " <> token)

      @doc """
      Convert the given givne into its generated sql
      """
      def to_sql(query) do
        {sql, _params} = @repo.to_sql(:all, query)
        sql
      end

      @doc """
      Asserts that the given query matches the given string
      """
      def assert_sql(sql, fragments) do
        for fragment <- fragments do
          assert sql =~ fragment
        end

        sql
      end

      @doc """
      Asserts that the given query does not match the given string
      """
      def refute_sql(sql, fragments) do
        for fragment <- fragments do
          refute sql =~ fragment
        end

        sql
      end
    end
  end
end

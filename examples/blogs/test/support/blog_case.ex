defmodule Blog.Case do
  @moduledoc "A base template for all test cases"
  use ExUnit.CaseTemplate

  using do
    quote do
      use Plug.Test

      import Ecto
      import Ecto.Query
      import Blog.Case

      alias Ecto.Adapters.SQL.Sandbox
      alias Blog.Repo

      @options Blog.Router.init([])

      setup tags do
        :ok = Sandbox.checkout(Repo)

        unless tags[:async] do
          Sandbox.mode(Repo, {:shared, self()})
        end

        :ok
      end

      defp get(path, opts \\ []), do: request(:get, path, opts)
      defp post(path, opts \\ []), do: request(:post, path, opts)
      defp put(path, opts \\ []), do: request(:put, path, opts)
      defp delete(path, opts \\ []), do: request(:delete, path, opts)

      defp post_json(path, data, opts \\ []) do
        method = opts[:method] || :post
        data = Jason.encode!(data)
        headers = opts[:headers] || %{}
        headers = Map.put(headers, "content-type", "application/json")

        request(method, path, headers: headers, params: data)
      end

      defp request(method, path, opts) do
        conn =
          method
          |> conn(path, opts[:params])
          |> with_req_headers(opts[:headers] || %{})
          |> Blog.Router.call(@options)
      end

      defp with_req_headers(conn, headers) do
        Enum.reduce(headers, conn, fn {key, value}, conn ->
          put_req_header(conn, key, value)
        end)
      end

      defp json_response(conn, status \\ 200) do
        assert :sent == conn.state
        assert status == conn.status
        Jason.decode!(conn.resp_body)
      end
    end
  end
end

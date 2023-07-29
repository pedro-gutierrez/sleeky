defmodule Sleeky.Rest.OpenApi do
  @moduledoc false

  import Sleeky.Inspector

  def ast(rest, schema) do
    module_name = module(rest, OpenApi)
    openapi = openapi(schema)

    quote do
      defmodule unquote(module_name) do
        @behaviour Plug
        @json "application/json"
        @openapi unquote(openapi)
        import Plug.Conn

        def init(opts), do: opts

        def call(conn, _opts) do
          conn
          |> put_resp_content_type(@json)
          |> send_resp(200, @openapi)
        end
      end
    end
  end

  def openapi(_schema) do
    ""
  end
end

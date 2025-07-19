defmodule Sleeky.Ui.Generator.Router do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(ui, opts) do
    caller = opts[:caller_module]
    router_module = Module.concat(caller, Router)

    conn = var(:conn)

    not_found_view = ui.not_found_view

    routes = Enum.map(ui.namespaces, &route(ui, &1))

    quote do
      defmodule unquote(router_module) do
        @moduledoc false
        use Plug.Router
        import Plug.Conn

        @html "text/html"

        plug Plug.Parsers, parsers: [:urlencoded, :multipart], length: 20_000_000, pass: ["*/*"]
        plug Plug.MethodOverride

        plug(:match)
        plug(:dispatch)

        unquote_splicing(routes)

        match _ do
          html = unquote(not_found_view).render(unquote(conn).params)
          send_html(unquote(conn), html, 404)
        end

        defp send_html(conn, body, status \\ 200) do
          conn
          |> put_resp_content_type(@html)
          |> send_resp(status, body)
        end
      end

      # convenience function that hides the fact tuat the actual router is implemented in a separate module
      defdelegate call(conn, opts \\ []), to: unquote(router_module)
    end
  end

  defp route(_ui, ns) do
    router = Module.concat(ns, Router)

    quote do
      forward unquote(ns).path(), to: unquote(router)
    end
  end
end

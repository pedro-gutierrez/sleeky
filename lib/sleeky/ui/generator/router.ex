defmodule Sleeky.Ui.Generator.Router do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(ui, opts) do
    caller = opts[:caller_module]
    module_name = Module.concat(caller, Router)

    conn = var(:conn)

    routes = Enum.map(ui.pages, &route/1)

    quote do
      defmodule unquote(module_name) do
        @moduledoc false
        use Plug.Router
        import Plug.Conn

        @html "text/html"

        plug(:match)
        plug(:dispatch)

        defp send_html(conn, body, status \\ 200) do
          conn
          |> put_resp_content_type(@html)
          |> send_resp(status, body)
        end

        unquote_splicing(routes)

        match _ do
          send_html(unquote(conn), "<h1>Not Found</h1>", 404)
        end
      end
    end
  end

  defp route(page) do
    conn = var(:conn)

    quote do
      match unquote(page.path), via: unquote(page.method) do
        html = unquote(page.module).render(unquote(conn).params)
        send_html(unquote(conn), html, 200)
      end
    end
  end
end

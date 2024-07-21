defmodule Sleeky.Ui.Generator.Router do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(ui, opts) do
    caller = opts[:caller_module]
    module_name = Module.concat(caller, Router)

    conn = var(:conn)

    routes =
      for {path, page} <- ui.pages do
        html = page.render()

        quote do
          get unquote(path) do
            send_html(unquote(conn), unquote(html), 200)
          end
        end
      end

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
end

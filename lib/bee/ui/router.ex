defmodule Bee.UI.Router do
  @moduledoc false
  import Bee.Inspector

  alias Bee.UI.View

  def ast(ui, views, _schema) do
    router = module(ui, Router)
    routes = for view <- views, do: route(view)

    conn = var(:conn)

    quote do
      defmodule unquote(router) do
        @moduledoc false
        use Plug.Router
        import Plug.Conn

        @html "text/html"
        @javascript "text/javascript"

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

  defp route(%View{module: view, route: route}) do
    html = view.render()
    conn = var(:conn)

    quote do
      get unquote(route) do
        send_html(unquote(conn), unquote(html), 200)
      end
    end
  end
end

defmodule Bee.UI.Router do
  @moduledoc false
  import Bee.Inspector

  alias Bee.UI.View

  def ast(ui, views) do
    router = module(ui, Router)
    routes = for view <- views, do: route(view)
    conn = var(:conn)

    quote do
      defmodule unquote(router) do
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

  defp route(%View{module: module, route: route, render: :compilation}) do
    html = render(module)
    conn = var(:conn)

    quote do
      get unquote(route) do
        send_html(unquote(conn), unquote(html), 200)
      end
    end
  end

  defp route(%View{module: module, route: route, render: :runtime}) do
    conn = var(:conn)

    quote do
      get unquote(route) do
        send_html(unquote(conn), unquote(module).render(), 200)
      end
    end
  end

  defp render(view) do
    view.render()
  rescue
    e ->
      IO.puts("""
      Error rendering view #{inspect(view)} with content:

      #{inspect(view.content())}

      Reason:

      #{Exception.format(:error, e, __STACKTRACE__)}"
      """)
  end
end

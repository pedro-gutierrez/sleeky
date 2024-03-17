defmodule Sleeky.Ui.Generators.Router do
  @moduledoc """
  A Diesel generator that produces a Plug.Router for a Sleeky Ui
  """
  import Sleeky.Inspector
  @behaviour Diesel.Generator

  @impl true
  def generate(ui, definition) do
    router = module(ui, Router)
    conn = var(:conn)
    routes = [bindings_route(ui) | view_routes(definition)]

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

        defp send_js(conn, body, status \\ 200) do
          conn
          |> put_resp_content_type(@javascript)
          |> send_resp(status, body)
        end

        unquote_splicing(routes)

        match _ do
          send_html(unquote(conn), "<h1>Not Found</h1>", 404)
        end
      end
    end
  end

  defp bindings_route(ui) do
    route = "/assets/js/ui.js"
    conn = var(:conn)

    if Mix.env() == :dev do
      quote do
        get unquote(route) do
          js = unquote(ui).to_js()

          send_js(unquote(conn), js, 200)
        end
      end
    else
      js = ui.to_js()

      quote do
        get unquote(route) do
          send_js(unquote(conn), unquote(js), 200)
        end
      end
    end
  end

  defp view_routes(definition) do
    definition
    |> Enum.filter(fn {kind, _, _} -> kind == :view end)
    |> Enum.map(fn {:view, opts, [v]} ->
      {Keyword.get(opts, :at, view_path(v)), v}
    end)
    |> Enum.map(&view_route/1)
  end

  defp view_path(mod) do
    case mod
         |> Module.split()
         |> List.last()
         |> Inflex.underscore()
         |> to_string() do
      "index" -> "/"
      name -> "/#{name}"
    end
  end

  defp view_route({path, view}) do
    conn = var(:conn)

    if Mix.env() == :dev do
      quote do
        get unquote(path) do
          send_html(unquote(conn), unquote(view).to_html(), 200)
        end
      end
    else
      html = view.to_html()

      quote do
        get unquote(path) do
          send_html(unquote(conn), unquote(html), 200)
        end
      end
    end
  end
end

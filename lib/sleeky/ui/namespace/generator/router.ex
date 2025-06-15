defmodule Sleeky.Ui.Namespace.Generator.Router do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(ns, _opts) do
    routes =
      for route <- ns.routes do
        handler = Module.concat(route, Handler)

        quote do
          match(unquote(route).path(), via: unquote(route).method(), to: unquote(handler))
        end
      end

    conn = var(:conn)

    quote do
      defmodule Router do
        use Plug.Router

        plug Plug.Parsers, parsers: [:urlencoded, :multipart], pass: ["*/*"]
        plug Plug.MethodOverride
        plug(:match)
        plug(:dispatch)

        unquote_splicing(routes)

        match _ do
          send_resp(unquote(conn), 404, "Not Found")
        end
      end
    end
  end
end

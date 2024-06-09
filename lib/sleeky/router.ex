defmodule Sleeky.Router do
  @moduledoc """
  Builds a JSON API router
  """

  import Sleeky.Naming

  alias Sleeky.Router.Api

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    contexts = otp_app |> Application.fetch_env!(Sleeky) |> Keyword.fetch!(:contexts)
    conn = var(:conn)
    router = __CALLER__.module

    api_routes = Api.routes(router, contexts)
    api_handlers = Api.handlers(router, contexts)

    quote do
      use Plug.Router

      defmodule Api do
        @moduledoc false
        use Plug.Router
        import Sleeky.Router.Json

        plug(:match)

        plug(Plug.Parsers,
          parsers: [:urlencoded, :multipart, :json],
          pass: ["*/*"],
          json_decoder: Jason
        )

        plug(:dispatch)

        unquote_splicing(api_handlers)
        unquote_splicing(api_routes)

        match _ do
          send_json(unquote(conn), %{reason: :no_such_route}, 404)
        end
      end

      plug(Plug.Static, at: "/assets", from: {unquote(otp_app), "priv/assets"})
      plug(:match)
      plug(:dispatch)

      forward("/api", to: __MODULE__.Api)

      get "/health" do
        send_resp(unquote(conn), 200, "")
      end
    end
  end
end

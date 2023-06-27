defmodule Bee.Router do
  @moduledoc """
  A macro that sets up a standard router, including default paths for ui, api and api docs
  """
  import Bee.Inspector

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    context = context(__CALLER__.module)
    rest_router = module(context, Rest.Router)
    ui_router = module(context, UI.Router)
    redoc_ui = module(context, Rest.RedocUI)

    plugs =
      opts
      |> Keyword.get(:plugs, [])
      |> Enum.map(fn p ->
        quote do
          plug(unquote(p))
        end
      end)

    conn = var(:conn)

    for module <- [rest_router, ui_router, redoc_ui], do: Code.ensure_compiled!(module)

    quote do
      use Plug.Router

      plug(Plug.Static, at: "/assets", from: {unquote(otp_app), "priv/assets"})

      plug(:match)

      unquote_splicing(plugs)

      plug(Blog.PutUser)
      plug(:dispatch)

      forward("/api", to: unquote(rest_router))

      if Mix.env() == :dev do
        get("/doc", to: unquote(redoc_ui), init_opts: [spec_url: "/api/openapi.json"])
      end

      get "/health" do
        send_resp(unquote(conn), 200, "")
      end

      forward("/", to: unquote(ui_router))
    end
  end
end

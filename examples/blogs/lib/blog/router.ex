defmodule Blog.Router do
  @moduledoc false
  use Plug.Router

  plug(Plug.Static, at: "/assets", from: {:blog, "priv/assets"})

  plug(:match)
  plug(Blog.PutUser)
  plug(:dispatch)

  forward("/api", to: Blog.Rest.Router)
  forward("/facebook", to: Blog.Facebook)

  if Mix.env() == :dev do
    get("/doc", to: Blog.Rest.RedocUI, init_opts: [spec_url: "/api/openapi.json"])
  end

  get "/health" do
    send_resp(conn, 200, "")
  end

  forward("/", to: Blog.UI.Router)
end

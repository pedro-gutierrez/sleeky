defmodule Blog.Facebook do
  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(:dispatch)

  get "/oauth" do
    oauth_url = oauth_url("714947908637880", "http://localhost:4001/facebook/login", "foo")

    conn
    |> put_resp_header("Location", oauth_url)
    |> send_resp(302, "")
  end

  get "/login" do
    code = conn.params["code"]

    IO.inspect(code: code)
    IO.inspect(params: conn.params)

    conn
    |> send_resp(200, "login")
  end

  def oauth_url(app_id, redirect_uri, state) do
    "https://www.facebook.com/v17.0/dialog/oauth?client_id=#{app_id}&redirect_uri=#{redirect_uri}&state=#{state}"
  end
end

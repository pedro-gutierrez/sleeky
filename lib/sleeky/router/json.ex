defmodule Sleeky.Router.Json do
  @moduledoc false

  import Plug.Conn
  require Logger

  @media_type "application/vnd.api+json"

  def send_json(conn, body, status \\ 200) do
    if status >= 500, do: Logger.error("application error", reason: inspect(body))

    conn
    |> put_resp_content_type(@media_type)
    |> send_resp(status, Jason.encode!(body))
  end
end

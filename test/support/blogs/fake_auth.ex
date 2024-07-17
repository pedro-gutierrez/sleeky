defmodule Blogs.FakeAuth do
  @moduledoc false
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _) do
    case get_req_header(conn, "authorization") do
      ["user " <> id] ->
        assign(conn, :current_user, %{roles: [:user], id: id})

      _ ->
        assign(conn, :current_user, %{roles: [:guest]})
    end
  end
end

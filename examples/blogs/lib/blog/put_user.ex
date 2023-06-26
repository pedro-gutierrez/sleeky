defmodule Blog.PutUser do
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    user = user(conn)
    assign(conn, :current_user, user)
  end

  defp user(_conn) do
    %{id: "fb95e767-73df-49b2-951d-930b937c94f4", roles: [:admin]}
  end
end

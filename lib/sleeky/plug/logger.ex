defmodule Sleeky.Plug.Logger do
  @moduledoc false
  @behaviour Plug

  alias Plug.Conn
  require Logger

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    start = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      status = conn.status
      level = if status >= 500, do: :error, else: :info

      Logger.log(level, fn ->
        stop = System.monotonic_time()
        ms = System.convert_time_unit(stop - start, :native, :millisecond) |> Integer.to_string()
        status = Integer.to_string(status)

        [
          connection_type(conn),
          ?\s,
          conn.method,
          ?\s,
          conn.request_path,
          ?\s,
          status,
          " in ",
          ms,
          "ms"
        ]
      end)

      conn
    end)
  end

  defp connection_type(%{state: :set_chunked}), do: "Chunked"
  defp connection_type(_), do: "Sent"
end

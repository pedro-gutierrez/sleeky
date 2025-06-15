defmodule Sleeky.Endpoint.Logger do
  @moduledoc false
  @behaviour Plug

  alias Plug.Conn
  require Logger

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, opts) do
    if log_request?(opts) do
      do_log_request(conn)
    else
      conn
    end
  end

  defp log_request?(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    endpoint = Keyword.fetch!(opts, :endpoint)

    otp_app |> Application.get_env(endpoint) |> Keyword.get(:log_requests, false)
  end

  defp do_log_request(conn) do
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

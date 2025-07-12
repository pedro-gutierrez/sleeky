defmodule Sleeky.Api.ConnHelper do
  @moduledoc """
  Some helper functions around conn management
  """
  import Plug.Conn
  require Logger

  @doc """
  Builds a json response
  """
  def send_json(data, conn, opts \\ [])

  def send_json({:error, body}, conn, opts) do
    status = opts[:status] || status_code_from_error(body)

    send_json(body, conn, status: status)
  end

  def send_json(body, conn, opts) do
    status = opts[:status] || 200

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  defp status_code_from_error(%{reason: atom}) when is_atom(atom), do: Plug.Conn.Status.code(atom)

  defp status_code_from_error(errors) when is_map(errors) do
    Enum.reduce_while(errors, 400, fn {_, reasons}, default ->
      cond do
        "was not found" in reasons -> {:halt, 404}
        "has children" in reasons -> {:halt, 412}
        "has already been taken" in reasons -> {:halt, 409}
        true -> {:cont, default}
      end
    end)
  end
end

defmodule Sleeky.Router.Json do
  @moduledoc false

  import Plug.Conn
  require Logger

  @media_type "application/vnd.api+json"

  @doc """
  Ensures that the request content type is the expected one.

  This function is to be used as a plug in api router handlers.
  """
  def check_content_type(conn, _) do
    if get_req_header(conn, "content-type") == [@media_type] do
      conn
    else
      conn
      |> send_json(%{"error" => "content type"}, status: 400)
      |> halt()
    end
  end

  @doc """
  Validates the presence and the structure of the data field
  """
  def validate_data(nil), do: {:error, {:invalid, :data}}
  def validate_data(%Plug.Conn{} = conn), do: validate_data(conn.params["data"])
  def validate_data(data) when is_map(data), do: {:ok, data}
  def validate_data(_), do: {:error, {:invalid, :data}}

  @doc """
  Validates the json api type in the request
  """
  def validate_type(%{"type" => type}, type), do: {:ok, type}
  def validate_type(_data, _type), do: {:error, {:invalid, :type}}

  @doc """
  Validates the presence of a id
  """
  def validate_id(%{"id" => id}), do: validate_id(id)

  def validate_id(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, _} -> {:ok, id}
      :error -> {:error, {:invalid, :id}}
    end
  end

  def validate_id(_), do: {:error, {:invalid, :id}}

  @doc """
  Convenience function to format json responses.

  To be used by api router handlers.
  """
  def send_json(conn, error, opts \\ [status: 200])

  def send_json(conn, {:error, {:invalid, reason}}, _opts) do
    send_json(conn, %{"errors" => [%{"code" => reason}]}, status: 400)
  end

  def send_json(conn, {:error, reason}, _opts) do
    send_json(conn, %{"errors" => [%{"code" => reason}]}, status: 500)
  end

  def send_json(conn, body, opts) do
    status = opts[:status]

    if status >= 500, do: Logger.error("application error", reason: inspect(body))

    conn
    |> put_resp_content_type(@media_type)
    |> send_resp(status, Jason.encode!(body))
  end
end

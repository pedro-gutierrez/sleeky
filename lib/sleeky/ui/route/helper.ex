defmodule Sleeky.Ui.Route.Helper do
  @moduledoc """
  A helper module for converting results from ui actions into either html views or redirects
  """

  import Plug.Conn

  import Sleeky.Maps

  @doc """
  Converts the result of a ui action into either an html view or a redirect

  Inputs supported:

  * `{:render, view, model}` - Renders the specified view with the given model.
  * `{:redirect, path}` - Redirects to the specified path.
  * `{:error, :not_found}` - Renders the "not_found" view.
  * `{:error, reason}` - Renders the "error" view with the given reason.

  The rest of the parameters are:A

  * the conn struct
  * the params used as input to the action
  * the map of views available, indexed by view name
  """
  def result({:ok, model}, conn, params, views),
    do: result({:render, "default", model}, conn, params, views)

  def result(model, conn, params, views) when is_map(model),
    do: result({:render, "default", model}, conn, params, views)

  def result({:render, view, model}, conn, params, views) do
    model = string_keys(model)
    model = Map.merge(params, model)

    render_view(views, view, conn, model, 200)
  end

  def result({:redirect, path}, conn, _params, _views) do
    conn = put_resp_header(conn, "location", path)

    send_resp(conn, 302, "")
  end

  def result({:error, :not_found}, conn, params, views) do
    render_view(views, "not_found", conn, params, 404)
  end

  def result({:error, reason}, conn, params, views) do
    model = Map.put(params, "reason", inspect(reason))

    render_view(views, "error", conn, model, 500)
  end

  defp render_view(views, view, conn, model, status) do
    view = Map.fetch!(views, view)
    html = view.render(model)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(status, html)
  end
end

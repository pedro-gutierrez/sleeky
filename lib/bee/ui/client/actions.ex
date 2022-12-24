defmodule Bee.UI.Client.Actions do
  @moduledoc false

  import Bee.Inspector
  import Bee.UI.Client.Helpers

  alias Bee.Entity.Action
  alias ESTree.Tools.Builder, as: JS

  @json "application/json; charset=UTF-8"

  def ast(entity) do
    entity.actions
    |> Enum.map(&action/1)
    |> flatten()
  end

  defp action(%Action{name: :create} = action) do
    entity = action.entity
    url = url(entity)

    request = json_request("POST", [], "this.item")

    body =
      url
      |> fetch(request)
      |> decode_response()
      |> reload_store()
      |> handle_errors()

    async(action.name, [], [body])
  end

  defp action(%Action{name: :update} = action) do
    entity = action.entity
    url = url(entity, "item.id")
    params = [JS.identifier(entity.name())]

    request = json_request("PATCH", [], "item")

    body =
      url
      |> fetch(request)
      |> decode_response()
      |> reload_store()
      |> handle_errors()

    async(action.name, params, [body])
  end

  defp action(%Action{name: :read} = action) do
    entity = action.entity
    url = url(entity, "id")
    params = [id()]

    request = json_request("GET", [])

    body =
      url
      |> fetch(request)
      |> decode_response()
      |> reload_store()
      |> handle_errors()

    async(action.name, params, [body])
  end

  defp action(%Action{name: :list} = action) do
    entity = action.entity
    url = url(entity)

    request = json_request("GET", [])

    body =
      url
      |> fetch(request)
      |> decode_response()
      |> set_items()
      |> handle_errors()

    async(action.name, [], [body])
  end

  defp action(%Action{name: :delete} = action) do
    entity = action.entity
    url = url(entity, "id")
    params = [id()]

    request = json_request("DELETE", [])

    body =
      url
      |> fetch(request)
      |> decode_response()
      |> reload_store()
      |> handle_errors()

    async(action.name, params, [body])
  end

  defp action(%Action{name: _}) do
    nil
  end

  defp method(method) do
    JS.property(
      JS.identifier("method"),
      JS.literal(method)
    )
  end

  defp content_type(mime) do
    JS.property(
      JS.literal("content-type"),
      JS.literal(mime)
    )
  end

  defp accept(mime) do
    JS.property(
      JS.identifier("accept"),
      JS.literal(mime)
    )
  end

  defp body(var) do
    JS.property(
      JS.identifier("body"),
      call("JSON.stringify", [JS.identifier(var)])
    )
  end

  defp json_request(method, headers, body) do
    request(method, [accept(@json), content_type(@json) | headers], body)
  end

  defp json_request(method, headers) do
    request(method, [accept(@json), content_type(@json) | headers])
  end

  defp request(method, headers) do
    JS.object_expression([
      method(method),
      headers(headers)
    ])
  end

  defp request(method, headers, body) do
    JS.object_expression([
      method(method),
      headers(headers),
      body(body)
    ])
  end

  defp headers(headers) do
    JS.property(
      JS.identifier("headers"),
      JS.object_expression(headers)
    )
  end

  defp fetch(url, request) do
    JS.await_expression(call("fetch", [url, request]))
  end

  defp url(entity) do
    JS.literal("/api/#{entity.plural()}")
  end

  defp url(entity, path_param) do
    template("/api/#{entity.plural()}/", path_param)
  end

  defp decode_response(callee) do
    promise_then(callee, [response()], [
      JS.if_statement(
        JS.member_expression(
          response(),
          JS.identifier("ok")
        ),
        JS.return_statement(call("response.json", []))
      ),
      reject_promise()
    ])
  end

  defp reload_store(callee) do
    promise_then(callee, [response()], [
      call("this.list", [])
    ])
  end

  defp set_items(callee) do
    promise_then(callee, [response()], [
      JS.assignment_expression(
        :=,
        JS.identifier("this.items"),
        response()
      )
    ])
  end

  defp handle_errors(callee) do
    promise_catch(callee, [error()], [
      log(error())
    ])
  end
end

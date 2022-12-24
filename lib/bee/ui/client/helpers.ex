defmodule Bee.UI.Client.Helpers do
  @moduledoc false

  alias ESTree.Tools.Builder, as: JS
  alias ESTree.Tools.Generator

  def null, do: JS.identifier(:null)
  def falsy, do: JS.identifier(false)
  def empty, do: JS.literal("")
  def response, do: JS.identifier(:response)
  def items, do: JS.identifier(:items)
  def item, do: JS.identifier(:item)
  def id, do: JS.identifier(:id)
  def error, do: JS.identifier(:error)

  def log(something) do
    call("console.log", [something])
  end

  def reject_promise do
    JS.return_statement(call("Promise.reject", [response()]))
  end

  def template(prefix, ident) do
    JS.template_literal(
      [
        JS.template_element(
          prefix,
          prefix,
          true,
          JS.source_location(
            nil,
            JS.position(0, 1),
            JS.position(0, String.length(prefix))
          )
        )
      ],
      [
        JS.identifier(
          ident,
          JS.source_location(
            nil,
            JS.position(0, String.length(prefix) + 1),
            JS.position(0, String.length(prefix) + 1 + String.length(ident))
          )
        )
      ]
    )
  end

  def promise_then(callee, args, body) do
    promise_chain(callee, "then", args, body)
  end

  def promise_catch(callee, args, body) do
    promise_chain(callee, "catch", args, body)
  end

  defp promise_chain(callee, op, args, body) do
    call(callee, op, [
      JS.arrow_function_expression(
        args,
        [],
        JS.block_statement(body),
        false,
        false
      )
    ])
  end

  def call(function, params) when is_binary(function) do
    JS.call_expression(
      JS.identifier(function),
      params
    )
  end

  def call(object, member, params) do
    JS.call_expression(
      JS.member_expression(
        object,
        JS.identifier(member)
      ),
      params
    )
  end

  def async(name, params, statements) do
    JS.function_declaration(
      JS.identifier(name),
      params,
      [],
      JS.block_statement(statements),
      false,
      false,
      true
    )
  end

  def async_arrow_function(block) do
    JS.arrow_function_expression(
      [],
      [],
      JS.block_statement(block),
      false,
      false,
      true
    )
  end

  def event_listener(block, event) do
    event = JS.literal(event)
    expr = async_arrow_function(block)
    call("document.addEventListener", [event, expr])
  end

  def render(ast) do
    ast
    |> Generator.generate()
    |> String.replace("function ", "")
    |> String.replace("(await", "await")
    |> String.replace("})).", "}).")
  end
end

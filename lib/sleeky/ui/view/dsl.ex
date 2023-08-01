defmodule Sleeky.UI.View.Dsl do
  @moduledoc """
  Provides with the Sleeky view DSL.

  This module:

  * provides the `render` macro for views to implement, and
  * recusively parses and cleans up the obtained AST into an internal view definition:

  Example:

  ```elixir
  render do
    span class: "foo" do
      "Hello"
    end
  end
  ```

  is parsed into:

  ```elixir
  {:span, [class: "foo"], ["Hello"]}
  ```
  """

  defmacro render(do: raw) do
    view = __CALLER__.module
    definition = parse(raw)
    Module.put_attribute(view, :definition, definition)
  end

  defp parse({:__aliases__, _, module}) do
    Module.concat(module)
  end

  defp parse({node, _, [attrs, [do: children]]}) when is_list(children) do
    {node, parse(attrs), parse(children)}
  end

  defp parse({node, _, [attrs, [do: {:__block__, _, children}]]})
       when is_list(children) do
    {node, parse(attrs), parse(children)}
  end

  defp parse({node, _, [attrs, [do: child]]}) do
    {node, parse(attrs), [parse(child)]}
  end

  defp parse({node, _, [[do: children]]}) when is_list(children) do
    {node, [], parse(children)}
  end

  defp parse({node, _, [[do: {:__block__, _, children}]]}) when is_list(children) do
    {node, [], parse(children)}
  end

  defp parse({node, _, [[do: child]]}) do
    {node, [], [parse(child)]}
  end

  defp parse({node, _, [do: children]}) when is_list(children) do
    {node, [], parse(children)}
  end

  defp parse({node, _, [do: child]}) do
    {node, [], [parse(child)]}
  end

  defp parse({node, _, [attrs]}) when is_list(attrs) do
    {node, parse(attrs), []}
  end

  defp parse({node, _, children}) do
    {node, [], parse(children)}
  end

  defp parse(nodes) when is_list(nodes) do
    for node <- nodes, do: parse(node)
  end

  defp parse({node, value}), do: {parse(node), parse(value)}

  defp parse({:__block__, _, nodes}), do: parse(nodes)
  defp parse(atom) when is_atom(atom), do: atom
  defp parse(text) when is_binary(text), do: text
end

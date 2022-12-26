defmodule Bee.UI.View.Dsl do
  @moduledoc false

  defmacro render(do: raw) do
    view = __CALLER__.module
    clean = cleanup(raw)
    Module.put_attribute(view, :definition, clean)
  end

  def cleanup({:__aliases__, _, module}) do
    Module.concat(module)
  end

  def cleanup({node, [line: _], [attrs, [do: children]]}) when is_list(children) do
    {node, cleanup(attrs), cleanup(children)}
  end

  def cleanup({node, [line: _], [attrs, [do: {:__block__, _, children}]]})
      when is_list(children) do
    {node, cleanup(attrs), cleanup(children)}
  end

  def cleanup({node, [line: _], [attrs, [do: child]]}) do
    {node, cleanup(attrs), [cleanup(child)]}
  end

  def cleanup({node, [line: _], [[do: children]]}) when is_list(children) do
    {node, [], cleanup(children)}
  end

  def cleanup({node, [line: _], [[do: {:__block__, [], children}]]}) when is_list(children) do
    {node, [], cleanup(children)}
  end

  def cleanup({node, [line: _], [[do: child]]}) do
    {node, [], [cleanup(child)]}
  end

  def cleanup({node, [line: _], [do: children]}) when is_list(children) do
    {node, [], cleanup(children)}
  end

  def cleanup({node, [line: _], [do: child]}) do
    {node, [], [cleanup(child)]}
  end

  def cleanup({node, [line: _], [attrs]}) when is_list(attrs) do
    {node, cleanup(attrs), []}
  end

  def cleanup({node, [line: _], children}) do
    {node, [], cleanup(children)}
  end

  def cleanup(nodes) when is_list(nodes) do
    for node <- nodes, do: cleanup(node)
  end

  def cleanup({node, value}), do: {cleanup(node), cleanup(value)}

  def cleanup({:__block__, [], nodes}), do: cleanup(nodes)
  def cleanup(atom) when is_atom(atom), do: atom
  def cleanup(text) when is_binary(text), do: text
end

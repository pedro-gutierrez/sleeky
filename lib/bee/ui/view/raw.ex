defmodule Bee.UI.View.Raw do
  def parse({:__aliases__, _, module}) do
    Module.concat(module)
  end

  def parse({node, [line: _], [attrs, [do: children]]}) when is_list(children) do
    {node, parse(attrs), parse(children)}
  end

  def parse({node, [line: _], [attrs, [do: {:__block__, _, children}]]})
      when is_list(children) do
    {node, parse(attrs), parse(children)}
  end

  def parse({node, [line: _], [attrs, [do: child]]}) do
    {node, parse(attrs), [parse(child)]}
  end

  def parse({node, [line: _], [[do: children]]}) when is_list(children) do
    {node, [], parse(children)}
  end

  def parse({node, [line: _], [[do: {:__block__, [], children}]]}) when is_list(children) do
    {node, [], parse(children)}
  end

  def parse({node, [line: _], [[do: child]]}) do
    {node, [], [parse(child)]}
  end

  def parse({node, [line: _], [do: children]}) when is_list(children) do
    {node, [], parse(children)}
  end

  def parse({node, [line: _], [do: child]}) do
    {node, [], [parse(child)]}
  end

  def parse({node, [line: _], [attrs]}) when is_list(attrs) do
    {node, parse(attrs), []}
  end

  def parse({node, [line: _], children}) do
    {node, [], parse(children)}
  end

  def parse(nodes) when is_list(nodes) do
    for node <- nodes, do: parse(node)
  end

  def parse({node, value}), do: {parse(node), parse(value)}

  def parse({:__block__, [], nodes}), do: parse(nodes)
  def parse(atom) when is_atom(atom), do: atom
  def parse(text) when is_binary(text), do: text
end

defmodule Sleeky.Ui.Render do
  @moduledoc """
  Renders a view's internal definition into Html.

  The rendering phase happens once the view has been fully resolved
  """

  @self_closing_tags [
    :area,
    :base,
    :br,
    :col,
    :embed,
    :hr,
    :img,
    :input,
    :keygen,
    :link,
    :meta,
    :param,
    :source,
    :track,
    :wbr
  ]

  @doc """
  Renders a view as html

  The view is represented by its internal definition, which is a floki-like datastructure made of
  nested tuples
  """
  @spec to_html(tuple()) :: String.t()
  def to_html(data), do: "<!DOCTYPE html>#{do_tags(data)}"

  defp do_tags({tag, attrs, _}) when tag in @self_closing_tags do
    "<#{tag}#{do_attrs(attrs)}>"
  end

  defp do_tags({tag, attrs, children}) do
    "<#{tag}#{do_attrs(attrs)}>#{do_tags(children)}</#{tag}>"
  end

  defp do_tags(items) when is_list(items) do
    Enum.map(items, &do_tags/1)
  end

  defp do_tags(literal) when is_binary(literal) or is_number(literal) or is_number(literal) do
    literal
  end

  defp do_tags(atom) when is_atom(atom), do: to_string(atom)

  defp do_attrs([]), do: ""

  defp do_attrs(attrs) do
    " #{Enum.map_join(attrs, " ", &do_attr/1)}"
  end

  defp do_attr({name, _}) when name in [:defer] do
    "#{name}"
  end

  defp do_attr({name, value}) when is_boolean(value) do
    "#{name}=#{value}"
  end

  defp do_attr({name, value}) do
    "#{name}=\"#{value}\""
  end
end

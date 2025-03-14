defmodule Sleeky.Ui.View.Render do
  @moduledoc false

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

  def render([]), do: []

  def render({:html, _, _} = view), do: ["<!DOCTYPE html>", do_tags(view)]
  def render(view), do: do_tags(view)

  defp do_tags({tag, attrs, _}) when tag in @self_closing_tags,
    do: ["<", to_string(tag), do_attrs(attrs), " >"]

  defp do_tags({tag, attrs, children}) do
    tag = to_string(tag)

    ["<", tag, do_attrs(attrs), ">", do_tags(children), "</", tag, ">"]
  end

  defp do_tags(elements) when is_list(elements), do: Enum.map(elements, &do_tags/1)

  defp do_tags(value) when is_binary(value) or is_number(value) or is_number(value), do: value

  defp do_tags(atom) when is_atom(atom), do: to_string(atom)

  defp do_attrs([]), do: []

  defp do_attrs(attrs), do: Enum.map(attrs, &[" ", do_attr(&1)])

  defp do_attr({name, value}) when value in [true, "true"], do: to_string(name)
  defp do_attr({_name, value}) when value in [false, "false"], do: ""

  # defp do_attr({name, value}) when is_boolean(value), do: [to_string(name), "=", to_string(value)]
  defp do_attr({name, value}), do: [to_string(name), "=\"", to_string(value), "\""]
end

defmodule Sleeky.Ui.Html do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [div: 2]
      import Sleeky.Ui.Html
    end
  end

  @tags [
    :a,
    :abbr,
    :address,
    :area,
    :article,
    :aside,
    :audio,
    :b,
    :base,
    :bdi,
    :bdo,
    :blockquote,
    :body,
    :br,
    :button,
    :canvas,
    :caption,
    :cite,
    :code,
    :col,
    :colgroup,
    :data,
    :datalist,
    :dd,
    :del,
    :details,
    :dfn,
    :dialog,
    :div,
    :dl,
    :dt,
    :em,
    :embed,
    :fieldset,
    :figcaption,
    :figure,
    :footer,
    :form,
    :h1,
    :h2,
    :h3,
    :h4,
    :h5,
    :h6,
    :head,
    :header,
    :hr,
    :html,
    :i,
    :iframe,
    :img,
    :input,
    :ins,
    :kbd,
    :label,
    :legend,
    :li,
    :link,
    :main,
    :map,
    :mark,
    :meta,
    :meter,
    :nav,
    :noscript,
    :object,
    :ol,
    :optgroup,
    :option,
    :output,
    :p,
    :param,
    :picture,
    :pre,
    :progress,
    :q,
    :rp,
    :rt,
    :ruby,
    :s,
    :samp,
    :script,
    :section,
    :select,
    :small,
    :source,
    :span,
    :strong,
    :style,
    :sub,
    :summary,
    :sup,
    :svg,
    :table,
    :tbody,
    :td,
    :template,
    :textarea,
    :tfoot,
    :th,
    :thead,
    :time,
    :title,
    :tr,
    :track,
    :u,
    :ul,
    :var,
    :video,
    :wbr
  ]

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

  for tag <- @tags do
    defmacro unquote(tag)(attrs, do: {:__block__, _, children}) do
      {:el, [line: 1], [unquote(tag), attrs, children]}
    end

    defmacro unquote(tag)(attrs, do: child) do
      {:el, [line: 1], [unquote(tag), attrs, child]}
    end

    defmacro unquote(tag)(do: {:__block__, _, children}) do
      {:el, [line: 1], [unquote(tag), [], children]}
    end

    defmacro unquote(tag)(do: child) do
      {:el, [line: 1], [unquote(tag), [], child]}
    end

    defmacro unquote(tag)(attrs) when is_list(attrs) do
      {:el, [line: 1], [unquote(tag), attrs, []]}
    end

    defmacro unquote(tag)(other) do
      {:el, [line: 1], [unquote(tag), [], other]}
    end
  end

  def el(tag, attrs, children) when is_list(children), do: {tag, attrs, children}
  def el(tag, attrs, child), do: {tag, attrs, [child]}

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

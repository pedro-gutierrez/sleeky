defmodule Sleeky.Ui.Html do
  @moduledoc """
  Provides with basic Html support:

  * a DSL to define views with valid html markup, and translate into its internal definition
  * resolution and sanitization of internal definitions
  """

  defmodule Dsl do
    @moduledoc false

    defmacro __using__(_opts) do
      quote do
        import Kernel, except: [div: 2]
        import Sleeky.Ui.Html.Dsl
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
  end

  defmodule Resolve do
    @moduledoc false

    defmacro __using__(_opts) do
      quote do
        def resolve({node, attrs, children}, args) do
          {node, attrs |> resolve(args) |> sanitize_attrs(args), resolve(children, args)}
        end

        def resolve({node, children}, args) when is_list(children) do
          {node, [], resolve(children, args)}
        end

        def resolve(nodes, args) when is_list(nodes) do
          for n <- nodes, do: resolve(n, args)
        end

        def resolve({name, value}, args) do
          {name, resolve(value, args)}
        end

        def resolve(other, _args) when is_binary(other) or is_number(other) or is_atom(other) do
          other
        end

        defp sanitize_attrs(attrs, args) do
          for {name, value} <- attrs, do: {name, sanitize_attr(value, args)}
        end

        defp sanitize_attr([value], args), do: sanitize_attr(value, args)

        defp sanitize_attr(value, args) when is_binary(value) do
          args = string_keys(args)

          value
          |> Solid.parse!()
          |> Solid.render!(args, strict_variables: true)
          |> to_string
        rescue
          _ ->
            raise "Error rendering attribute #{value} with args #{inspect(Map.keys(args))}"
        end

        defp sanitize_attr(value, _args)
             when is_boolean(value) or is_number(value),
             do: value

        defp sanitize_attr(value, _args) when is_atom(value), do: to_string(value)

        defp string_keys(map) do
          for {key, value} <- map, into: %{}, do: {to_string(key), value}
        end
      end
    end
  end
end

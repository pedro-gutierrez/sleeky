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

    @doc false
    def locals_without_parens, do: Enum.map(@tags, &{&1, :*})

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
          {node, attrs |> resolve_attrs(args), resolve(children, args)}
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

        def resolve(value, args) when is_binary(value) do
          case templated_value(value, args) do
            {:ok, value} ->
              value

            {:error, reason} ->
              raise "Error rendering #{value} with args #{inspect(args)}: #{inspect(reason)}"
          end
        end

        def resolve(other, _args) when is_number(other) or is_boolean(other), do: other
        def resolve(other, _args) when is_atom(other), do: to_string(other)

        defp resolve_attrs(attrs, args) do
          for {name, value} <- attrs do
            try do
              {name, resolve(value, args)}
            rescue
              error ->
                raise "Error rendering attribute #{name} with args #{inspect(args)}: #{inspect(error)}"
            end
          end
        end

        defp string_keys(map) when is_map(map),
          do: for({key, value} <- map, into: %{}, do: {to_string(key), string_keys(value)})

        defp string_keys(items) when is_list(items), do: Enum.map(items, &string_keys/1)
        defp string_keys(other), do: other

        defp templated_value(tpl, args) do
          with {:ok, tpl} <- Solid.parse(tpl),
               args <- args |> Enum.into(%{}) |> string_keys(),
               {:ok, rendered} <- Solid.render(tpl, args, strict_variables: true) do
            {:ok, to_string(rendered)}
          else
            _ ->
              {:error, :template_error}
          end
        end
      end
    end
  end
end

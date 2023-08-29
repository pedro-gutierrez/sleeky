defmodule Sleeky.Ui.Markdown do
  @moduledoc """
  Markdown views that resolve into html.

  ```elixir
  defmodule MyApp.Ui.BlogPostView do
    use Sleeky.View

    render do
      article do
        h1 "Sleeky supports Markdown"
        div do
          markdown do
            \"\"\"
            # Summary

            This is **markdown**"
            \"\"\"
          end
        end
      end
    end
  end
  ```
  """

  defmodule Dsl do
    @moduledoc false

    @doc false
    def locals_without_parens, do: [markdown: :*]

    defmacro __using__(_opts) do
      quote do
        import Sleeky.Ui.Markdown.Dsl
      end
    end

    defmacro markdown(do: content) do
      quote do
        {:markdown, [], [unquote(content)]}
      end
    end

    defmacro markdown(attrs, do: content) do
      quote do
        {:markdown, unquote(attrs), [unquote(content)]}
      end
    end

    defmacro markdown(content) when is_binary(content) do
      quote do
        {:markdown, [], [unquote(content)]}
      end
    end
  end

  defmodule Resolve do
    @moduledoc false

    defmacro __using__(_opts) do
      quote do
        import Sleeky.Ui.Markdown.Resolve

        def resolve({:markdown, attrs, [content]}, args) when is_binary(content) do
          case content |> resolve(args) |> EarmarkParser.as_ast() do
            {:ok, ast, []} ->
              {:div, attrs, [definition(ast)]}

            other ->
              raise "Error parsing markdown #{content}: #{inspect(other)}"
          end
        end
      end
    end

    def definition(nodes) when is_list(nodes), do: Enum.map(nodes, &definition/1)
    def definition(text) when is_binary(text), do: text

    def definition({tag, attrs, children, _}) do
      {String.to_existing_atom(tag), attrs, definition(children)}
    end
  end
end

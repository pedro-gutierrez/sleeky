defmodule Sleeky.Ui.View.Dsl.Markdown do
  @moduledoc """
  Markdown views that compile into html.

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
  use Diesel.Package, tags: [:markdown]

  @impl true
  def compiler do
    quote do
      def compile({:markdown, attrs, [content]}, ctx) when is_binary(content) do
        case content |> compile(ctx) |> EarmarkParser.as_ast() do
          {:ok, ast, []} when is_list(ast) ->
            {:div, attrs, atom_tags(ast)}

          {:ok, ast, []} ->
            {:div, attrs, [atom_tags(ast)]}

          other ->
            raise "Error parsing markdown #{content}: #{inspect(other)}"
        end
      end

      defp atom_tags(nodes) when is_list(nodes), do: Enum.map(nodes, &atom_tags/1)
      defp atom_tags(text) when is_binary(text), do: text

      defp atom_tags({tag, attrs, children, _}) do
        {String.to_existing_atom(tag), attrs, atom_tags(children)}
      end
    end
  end
end

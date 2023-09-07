defmodule Sleeky.Ui.Tools.Import do
  @moduledoc """
  Converts raw html and writes a new Sleeky view module.

  This tool is meant for development purposes only, and to be used via the `sleeky.ui.import` mix
    task. It relies on `String.to_atom/1` so please don't use in production.

  Usage:

  ```elixir
  iex> html = "<h1 class=\"title\">\nThis is a title\n</h1>\n"
  iex> Sleeky.Ui.Tools.Import.html(html, MyApp.Ui.MyTitle)
  Written lib/my_app/ui/my_title.ex
  :ok
  ```

  Depending on the html, the module generated might not be 100% well formatted, and might not even
    compile. This is more likely to happen in the presence of very long html attributes. It is up to
    the the developer to adjust the final result.

  Still, this tool should speed up the process of converting raw to html to Sleeky view syntax.
  """

  @doc """
  Converts the given ast into a view module
  """
  def view_module(html, module) do
    html
    |> floki_html()
    |> definition()
    |> render_dsl()
    |> Macro.to_string()
    |> into_view_module(module)
    |> Code.format_string!()
    |> prettify()
  end

  defp floki_html(html) do
    html
    |> String.replace("\n", "")
    |> Floki.parse_document!()
    |> List.first()
  end

  defp render_dsl({tag, attrs, children}) when is_list(children) do
    {tag, [line: 1], [attrs, [do: {:__block__, [], render_dsl(children)}]]}
  end

  defp render_dsl({tag, attrs, child}) do
    {tag, [line: 1], [attrs, [do: render_dsl(child)]]}
  end

  defp render_dsl(nodes) when is_list(nodes), do: Enum.map(nodes, &render_dsl/1)
  defp render_dsl(value), do: to_string(value)

  defp into_view_module(code, module) do
    """
    defmodule #{inspect(module)} do
      @moduledoc false
      use Sleeky.Ui.View

      render do
        #{code}
      end
    end
    """
  end

  defp prettify(code) do
    code
    |> Enum.join("")
    |> String.replace("([])", "")
    |> String.replace("(", " ")
    |> String.replace(")", "")
  end

  defp definition({:comment, _}), do: []

  defp definition(value) when is_binary(value), do: String.trim(value)

  defp definition(nodes) when is_list(nodes),
    do:
      nodes
      |> Enum.map(&definition/1)
      |> List.flatten()

  defp definition({tag, attrs, children}) do
    {String.to_atom(tag), attrs(attrs), definition(children)}
  end

  defp attrs(attrs),
    do: Enum.map(attrs, fn {name, value} -> {String.to_atom(name), value} end)
end

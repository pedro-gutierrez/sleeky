defmodule Sleeky.Ui.Dsl do
  @moduledoc false

  alias Sleeky.Ui.View

  import Sleeky.Inspector

  @doc false
  def locals_without_parens do
    [view: :*] ++
      Sleeky.Ui.View.Dsl.locals_without_parens() ++
      Sleeky.Ui.Html.Dsl.locals_without_parens() ++
      Sleeky.Ui.Compound.Dsl.locals_without_parens() ++
      Sleeky.Ui.Each.Dsl.locals_without_parens() ++
      Sleeky.Ui.Markdown.Dsl.locals_without_parens()
  end

  @doc false
  def tags do
    Sleeky.Ui.Html.Dsl.tags() ++
      Sleeky.Ui.Compound.Dsl.tags() ++
      Sleeky.Ui.Each.Dsl.tags() ++
      Sleeky.Ui.Markdown.Dsl.tags()
  end

  defmacro view({:__aliases__, _, mod}, opts \\ []) do
    ui = __CALLER__.module
    view = module(mod)
    route = opts[:at] || route(mod)
    view = View.new(module: view, route: route)
    Module.put_attribute(ui, :views, view)
  end

  defp route(view) when is_list(view) do
    case view
         |> List.last()
         |> Inflex.underscore()
         |> to_string() do
      "index" -> "/"
      name -> "/#{name}"
    end
  end
end

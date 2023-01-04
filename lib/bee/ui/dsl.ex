defmodule Bee.UI.Dsl do
  @moduledoc false

  alias Bee.UI.View

  import Bee.Inspector

  defmacro view({:__aliases__, _, mod}, opts \\ []) do
    ui = __CALLER__.module
    render = opts[:render] || :compilation
    view = module(mod)
    route = opts[:at] || route(mod)
    view = View.new(module: view, route: route, render: render)
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

defmodule Bee.UI.Dsl do
  @moduledoc false

  alias Bee.UI.View

  import Bee.Inspector

  defmacro view(route, mod, opts \\ []) do
    ui = __CALLER__.module
    render = opts[:render] || :compilation
    view = View.new(module: module(mod), route: route, render: render)
    Module.put_attribute(ui, :views, view)
  end
end

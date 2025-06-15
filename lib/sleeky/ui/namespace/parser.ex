defmodule Sleeky.Ui.Namespace.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Ui.Namespace

  @impl true
  def parse({:namespace, [name: path], routes}, _opts) do
    routes = for {:routes, _, routes} <- routes, do: routes
    routes = List.flatten(routes)

    %Namespace{path: path, routes: routes}
  end
end

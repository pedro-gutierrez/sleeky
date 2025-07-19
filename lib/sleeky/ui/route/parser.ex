defmodule Sleeky.Ui.Route.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Ui.Route

  @impl true
  def parse({:route, attrs, children}, opts) do
    caller = Keyword.fetch!(opts, :caller_module)
    caller_module_name = caller |> Module.split() |> List.last()
    ui_prefix = caller |> Module.split() |> Enum.take(2) |> Module.concat()
    method = attrs |> Keyword.get(:method, "get") |> String.to_atom()
    path = Keyword.fetch!(attrs, :name)

    model = for {:action, _, [module]} <- children, do: module

    views =
      for {:view, opts, [module]} <- children, into: [] do
        name = Keyword.get(opts, :name, "default")

        {name, module}
      end

    {action, views} =
      with {[], []} <- {model, views} do
        action = [Module.concat([ui_prefix, Actions, caller_module_name])]
        views = [{"default", Module.concat([ui_prefix, Views, caller_module_name])}]

        {action, views}
      end

    action = List.first(action)

    default_views = %{
      "not_found" => Module.concat(ui_prefix, Views.NotFound),
      "error" => Module.concat(ui_prefix, Views.Error)
    }

    views = Map.new(views)
    views = Map.merge(default_views, views)

    %Route{
      views: views,
      method: method,
      path: path,
      action: action
    }
  end
end

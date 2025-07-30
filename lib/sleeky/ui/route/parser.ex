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

    views =
      for {:view, opts, children} = view <- children, into: %{} do
        module = Keyword.get(opts, :name) || List.first(children)
        name = Keyword.get(opts, :for, "default")

        if module == nil do
          raise "Missing module for view in #{inspect(view)}"
        end

        {name, module}
      end

    action =
      with nil <- Keyword.get(attrs, :action) do
        Module.concat([ui_prefix, Actions, caller_module_name])
      end

    default_views = %{
      "default" => Module.concat([ui_prefix, Views, caller_module_name]),
      "not_found" => Module.concat(ui_prefix, Views.NotFound),
      "error" => Module.concat(ui_prefix, Views.Error)
    }

    views = Map.merge(default_views, views)

    %Route{
      views: views,
      method: method,
      path: path,
      action: action
    }
  end
end

defmodule Sleeky.Ui.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Ui
  alias Sleeky.Ui.Page

  @impl true
  def parse({:ui, _, children}, opts) do
    ui = Keyword.fetch!(opts, :caller_module)

    pages =
      for {:page, page, _} <- children do
        path = Keyword.fetch!(page, :at)
        module = Keyword.fetch!(page, :name)
        method = Keyword.get(page, :method, :get)

        %Page{
          method: method,
          path: path,
          module: module
        }
      end

    namespaces = for {:namespaces, _, modules} <- children, do: modules
    namespaces = List.flatten(namespaces)

    error_view = Module.concat(ui, Views.Error)
    not_found_view = Module.concat(ui, Views.NotFound)

    %Ui{
      pages: pages,
      namespaces: namespaces,
      error_view: error_view,
      not_found_view: not_found_view
    }
  end
end

defmodule Sleeky.Ui.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Ui
  alias Sleeky.Ui.Page

  @impl true
  def parse({:ui, _, pages}, _opts) do
    pages =
      for {:page, page, _} <- pages do
        path = Keyword.fetch!(page, :at)
        module = Keyword.fetch!(page, :name)
        method = Keyword.get(page, :method, :get)

        %Page{
          method: method,
          path: path,
          runtime: false,
          module: module
        }
      end

    %Ui{pages: pages}
  end
end

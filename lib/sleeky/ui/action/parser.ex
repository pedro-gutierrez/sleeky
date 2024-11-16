defmodule Sleeky.Ui.Action.Parser do
  @moduledoc false

  @behaviour Diesel.Parser

  alias Sleeky.Ui.Action
  alias Sleeky.Ui.Action.View
  alias Sleeky.Ui.Action.Redirect

  @impl true
  def parse({:action, [name: module], results}, _opts) do
    views =
      for {:on, [name: name, view: module], _} <- results do
        %View{name: name, module: module}
      end

    redirects =
      for {:on, [name: name, redirect: path], _} <- results do
        %Redirect{name: name, path: path}
      end

    %Action{module: module, results: views ++ redirects}
  end
end

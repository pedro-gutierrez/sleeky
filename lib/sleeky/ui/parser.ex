defmodule Sleeky.Ui.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Ui

  @impl true
  def parse({_, _, children}, opts) do
    caller = opts[:caller_module]

    pages =
      for {:page, _, [module]} <- children, into: %{} do
        {path(caller, module), module}
      end

    contexts = for {:context, _, [module]} <- children, do: module

    %Ui{pages: pages, contexts: contexts}
  end

  defp path(caller, module) do
    caller = Module.split(caller)

    path =
      module
      |> Module.split()
      |> Kernel.--(caller)
      |> Enum.map(&Inflex.parameterize/1)
      |> Enum.reject(&(&1 == "index"))
      |> Enum.join("/")
      |> String.replace("//", "/")

    "/" <> path
  end
end

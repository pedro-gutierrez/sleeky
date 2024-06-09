defmodule Sleeky.JsonApi.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  @impl true
  def parse(_caller, {:json_api, [], children}) do
    %Sleeky.JsonApi{}
    |> add_contexts(children)
  end

  defp add_contexts(api, children) do
    contexts = for {:context, [], [module]} <- children, do: module

    %{api | contexts: contexts}
  end
end

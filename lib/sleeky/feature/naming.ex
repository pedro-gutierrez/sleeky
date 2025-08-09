defmodule Sleeky.Feature.Naming do
  @moduledoc false

  def feature_module(caller) do
    case caller |> Module.split() |> Enum.reverse() do
      [_, kind | rest] when kind in ["Commands", "Handlers", "Queries"] ->
        rest |> Enum.reverse() |> Module.concat()

      other ->
        raise "Invalid module name #{inspect(caller)}: #{inspect(other)}"
    end
  end
end

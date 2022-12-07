defmodule Bee.Context.ListActions do
  @moduledoc false

  def ast(entities, _enums, opts) do
    repo = Keyword.fetch!(opts, :repo)

    entities
    |> Enum.reject(& &1.virtual?)
    |> Enum.flat_map(fn entity ->
      list_all_functions(entity, repo)
    end)
  end

  defp list_all_functions(entity, repo) do
    IO.inspect(entity: entity, repo: repo)
    []
  end
end

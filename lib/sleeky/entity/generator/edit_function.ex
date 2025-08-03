defmodule Sleeky.Entity.Generator.EditFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(entity, _) do
    [
      with_map_args(entity),
      with_keyword_args(entity)
    ]
  end

  defp with_map_args(entity) do
    quote do
      def edit(entity, attrs) when is_map(attrs) do
        entity
        |> update_changeset(attrs)
        |> unquote(entity.context).repo().update()
      end
    end
  end

  defp with_keyword_args(_entity) do
    quote do
      def edit(entity, attrs) when is_list(attrs) do
        attrs = Map.new(attrs)

        edit(entity, attrs)
      end
    end
  end
end

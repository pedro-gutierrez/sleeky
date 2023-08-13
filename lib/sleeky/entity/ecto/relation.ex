defmodule Sleeky.Entity.Ecto.Relation do
  @moduledoc false

  def ast(entity) do
    [
      relation_function(entity),
      unloaded_function()
    ]
  end

  defp relation_function(entity) do
    entity_module = entity.module
    pk_name = entity.primary_key.field

    quote do
      def relation(%unquote(entity_module){unquote(pk_name) => pk_value} = item, field) do
        with rel when rel != nil <- Map.get(item, field) do
          if unloaded?(rel) do
            key = {pk_value, field}

            with nil <- Process.get(key) do
              rel = item |> @repo.preload(field) |> Map.get(field)
              Process.put(key, rel)
              rel
            end
          else
            rel
          end
        end
      end
    end
  end

  defp unloaded_function do
    [
      quote do
        defp unloaded?(%{__struct__: Ecto.Association.NotLoaded}), do: true
      end,
      quote do
        defp unloaded?(_), do: false
      end
    ]
  end
end

defmodule Sleeky.Entity.Ecto.JsonEncoder do
  @moduledoc false
  import Sleeky.Inspector

  def ast(entity) do
    module_name = module(entity.module, JsonEncoder)

    attributes = names(entity.attributes)

    relations =
      for rel <- entity.parents, into: %{} do
        {rel.name, rel.column}
      end

    quote do
      defmodule unquote(module_name) do
        defimpl Jason.Encoder, for: unquote(entity.module) do
          @attributes unquote(attributes)
          @relations unquote(Macro.escape(relations))

          def encode(item, opts) do
            item
            |> Map.take(@attributes)
            |> with_relations(@relations, item)
            |> Jason.encode!()
          end

          defp with_relations(dest, rels, source) do
            Enum.reduce(rels, dest, fn {name, col}, d ->
              v =
                with %Ecto.Association.NotLoaded{} <- Map.get(source, name),
                     do: %{id: Map.get(source, col)}

              Map.put(d, name, v)
            end)
          end
        end
      end
    end
  end
end

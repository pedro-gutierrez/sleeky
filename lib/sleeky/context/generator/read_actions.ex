defmodule Sleeky.Context.Generator.ReadActions do
  @moduledoc false

  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(context, _) do
    fetch_by_id_functions(context) ++ fetch_by_unique_keys_functions(context)
  end

  defp fetch_by_id_functions(context) do
    for entity <- context.entities, %{name: :read} = action <- entity.actions() do
      entity_name = entity.name()
      action_fun_name = String.to_atom("read_#{entity_name}")

      quote do
        def unquote(action_fun_name)(id, context \\ %{}) do
          opts = context |> Map.take([:preload]) |> Keyword.new()

          with {:ok, entity} <- unquote(entity).fetch(id, opts),
               context <- Map.put(context, unquote(entity_name), entity),
               :ok <- allow(unquote(entity_name), unquote(action.name), context) do
            {:ok, entity}
          end
        end
      end
    end
  end

  defp fetch_by_unique_keys_functions(context) do
    for entity <- context.entities,
        %{name: :read} = action <- entity.actions(),
        %{unique?: true} = key <- entity.keys() do
      entity_name = entity.name()
      action_fun_name = String.to_atom("read_#{entity_name}_by_#{key.name}")
      fetch_fun_name = String.to_atom("fetch_by_#{key.name}")
      args = key.fields |> Enum.map(& &1.name) |> Enum.map(&var(&1))

      quote do
        def unquote(action_fun_name)(unquote_splicing(args), context \\ %{}) do
          opts = context |> Map.take([:preload]) |> Keyword.new()

          with {:ok, entity} <-
                 unquote(entity).unquote(fetch_fun_name)(unquote_splicing(args), opts),
               context <- Map.put(context, unquote(entity_name), entity),
               :ok <- allow(unquote(entity_name), unquote(action.name), context) do
            {:ok, entity}
          end
        end
      end
    end
  end
end

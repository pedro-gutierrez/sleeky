defmodule Sleeky.Feature.Generator.ReadActions do
  @moduledoc false

  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(feature, _) do
    fetch_by_id_functions(feature) ++ fetch_by_unique_keys_functions(feature)
  end

  defp fetch_by_id_functions(feature) do
    for model <- feature.models, %{name: :read} = action <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("read_#{model_name}")

      quote do
        def unquote(action_fun_name)(id, context \\ %{}) do
          opts = context |> Map.take([:preload]) |> Keyword.new()

          with {:ok, model} <- unquote(model).fetch(id, opts),
               context <- Map.put(context, unquote(model_name), model),
               :ok <- allow(unquote(model_name), unquote(action.name), context) do
            {:ok, model}
          end
        end
      end
    end
  end

  defp fetch_by_unique_keys_functions(feature) do
    for model <- feature.models,
        %{name: :read} = action <- model.actions(),
        %{unique?: true} = key <- model.keys() do
      model_name = model.name()
      action_fun_name = String.to_atom("read_#{model_name}_by_#{key.name}")
      fetch_fun_name = String.to_atom("fetch_by_#{key.name}")
      args = key.fields |> Enum.map(& &1.name) |> Enum.map(&var(&1))

      quote do
        def unquote(action_fun_name)(unquote_splicing(args), context \\ %{}) do
          opts = context |> Map.take([:preload]) |> Keyword.new()

          with {:ok, model} <-
                 unquote(model).unquote(fetch_fun_name)(unquote_splicing(args), opts),
               context <- Map.put(context, unquote(model_name), model),
               :ok <- allow(unquote(model_name), unquote(action.name), context) do
            {:ok, model}
          end
        end
      end
    end
  end
end

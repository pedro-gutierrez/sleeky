defmodule Sleeky.Model.Generator.FetchFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(model, _), do: [fetch_function(model), fetch_bang_function()]

  defp fetch_function(model) do
    quote do
      def fetch(id, opts \\ []) do
        repo = unquote(model.context).repo()
        preload = Keyword.get(opts, :preload, [])

        case __MODULE__ |> repo.get(id) |> repo.preload(preload) do
          nil -> {:error, :not_found}
          model -> {:ok, model}
        end
      end
    end
  end

  defp fetch_bang_function do
    quote do
      def fetch!(id, opts \\ []) do
        case fetch(id, opts) do
          {:error, :not_found} ->
            raise "record #{inspect(id)} of model #{inspect(__MODULE__)} not found"

          {:ok, model} ->
            model
        end
      end
    end
  end
end

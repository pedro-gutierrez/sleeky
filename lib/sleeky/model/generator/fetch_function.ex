defmodule Sleeky.Model.Generator.FetchFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(model, _) do
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
end

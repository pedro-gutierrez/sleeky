defmodule Sleeky.Model.Generator.FetchFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, model) do
    quote do
      def fetch(id) do
        case unquote(model.context).repo().get(__MODULE__, id) do
          nil -> {:error, :not_found}
          model -> {:ok, model}
        end
      end
    end
  end
end

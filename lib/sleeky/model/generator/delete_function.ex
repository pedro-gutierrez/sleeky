defmodule Sleeky.Model.Generator.DeleteFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, model) do
    quote do
      def delete(model) do
        with {:ok, _} <-
               model
               |> delete_changeset()
               |> unquote(model.context).repo().delete(),
             do: :ok
      end
    end
  end
end

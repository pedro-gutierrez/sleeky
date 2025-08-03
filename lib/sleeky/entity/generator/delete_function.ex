defmodule Sleeky.Entity.Generator.DeleteFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(entity, _) do
    quote do
      def delete(entity) do
        with {:ok, _} <-
               entity
               |> delete_changeset()
               |> unquote(entity.context).repo().delete(),
             do: :ok
      end
    end
  end
end

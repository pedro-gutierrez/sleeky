defmodule Sleeky.Model.Generator.CreateFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, model) do
    [
      with_map_args(model),
      with_keyword_args(model)
    ]
  end

  defp with_map_args(model) do
    quote do
      def create(attrs) when is_map(attrs) do
        %__MODULE__{}
        |> insert_changeset(attrs)
        |> unquote(model.context).repo().insert()
      end
    end
  end

  defp with_keyword_args(_model) do
    quote do
      def create(attrs) when is_list(attrs) do
        attrs
        |> Map.new()
        |> create()
      end
    end
  end
end

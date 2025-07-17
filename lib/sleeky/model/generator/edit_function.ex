defmodule Sleeky.Model.Generator.EditFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(model, _) do
    [
      with_map_args(model),
      with_keyword_args(model)
    ]
  end

  defp with_map_args(model) do
    quote do
      def edit(model, attrs) when is_map(attrs) do
        model
        |> update_changeset(attrs)
        |> unquote(model.domain).repo().update()
      end
    end
  end

  defp with_keyword_args(_model) do
    quote do
      def edit(model, attrs) when is_list(attrs) do
        attrs = Map.new(attrs)

        edit(model, attrs)
      end
    end
  end
end

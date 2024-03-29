defmodule Sleeky.Model.Generator.Actions do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, model) do
    [
      create_action_with_map_fun(model),
      create_action_with_list_fun(model)
    ]
  end

  defp create_action_with_map_fun(model) do
    quote do
      def create(attrs) when is_map(attrs) do
        %__MODULE__{}
        |> insert_changeset(attrs)
        |> unquote(model.context).repo().insert()
      end
    end
  end

  defp create_action_with_list_fun(_model) do
    quote do
      def create(attrs) when is_list(attrs) do
        attrs
        |> Map.new()
        |> create()
      end
    end
  end
end

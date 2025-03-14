defmodule Sleeky.Model.Generator.Cast do
  @moduledoc false

  @behaviour Diesel.Generator
  def generate(_model, _) do
    quote do
      def cast_values(attrs) when is_map(attrs) do
        Enum.reduce(@field_names -- [:id], %{}, fn field, acc ->
          Map.put(acc, field, Map.get(attrs, to_string(field)))
        end)
      end
    end
  end
end

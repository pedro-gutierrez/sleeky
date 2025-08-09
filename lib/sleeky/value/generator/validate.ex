defmodule Sleeky.Value.Generator.Validate do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_value, _opts) do
    quote do
      def validate(params) do
        changeset = changeset(params)

        if changeset.valid? do
          {:ok, apply_changes(changeset)}
        else
          {:error, changeset}
        end
      end
    end
  end
end

defmodule Sleeky.Model.Generator.Changesets do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, model) do
    [
      insert_changeset(model)
    ]
  end

  defp insert_changeset(_model) do
    quote do
      defp insert_changeset(%__MODULE__{} = model, attrs) do
        model
        |> cast(attrs, @fields_on_insert)
        |> validate_required(@required_fields)
      end
    end
  end
end

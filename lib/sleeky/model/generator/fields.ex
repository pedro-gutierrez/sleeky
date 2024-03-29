defmodule Sleeky.Model.Generator.FieldNames do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, model) do
    attrs =
      model.attributes
      |> Enum.reject(& &1.virtual?)
      |> Enum.reject(&(&1.name in [:inserted_at, :updated_at]))

    parents = Enum.filter(model.relations, &(&1.kind == :parent))

    fields_on_insert = Enum.map(attrs, & &1.name) ++ Enum.map(parents, & &1.column_name)

    required_fields =
      (attrs
       |> Enum.filter(& &1.required?)
       |> Enum.map(& &1.name)) ++
        (parents
         |> Enum.filter(& &1.required?)
         |> Enum.map(& &1.column_name))

    quote do
      @fields_on_insert unquote(fields_on_insert)
      @required_fields unquote(required_fields)
    end
  end
end

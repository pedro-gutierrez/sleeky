defmodule Sleeky.Entity.Ecto.FieldAttributes do
  @moduledoc false
  import Sleeky.Inspector

  def ast(entity) do
    [
      required_fields_attribute(entity),
      optional_fields_attribute(entity),
      computed_fields_attribute(entity),
      all_fields_attribute()
    ]
  end

  defp required_fields_attribute(entity) do
    attrs =
      entity.attributes |> Enum.filter(& &1.required?) |> Enum.reject(& &1.timestamp?) |> names()

    parents = entity.parents |> Enum.filter(& &1.required?) |> columns()

    quote do
      @required_fields unquote(attrs ++ parents)
    end
  end

  defp optional_fields_attribute(entity) do
    attrs = entity.attributes |> Enum.filter(&(!&1.required?)) |> names()
    parents = entity.parents |> Enum.filter(&(!&1.required?)) |> columns()

    quote do
      @optional_fields unquote(attrs ++ parents)
    end
  end

  defp computed_fields_attribute(entity) do
    attrs = entity.attributes |> Enum.filter(& &1.computed?) |> names()
    parents = entity.parents |> Enum.filter(& &1.computed?) |> columns()

    quote do
      @computed_fields unquote(attrs ++ parents)
    end
  end

  defp all_fields_attribute do
    quote do
      @all_fields @required_fields ++ @optional_fields
    end
  end
end

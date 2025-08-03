defmodule Sleeky.Migrations.Index do
  @moduledoc false

  alias Sleeky.Model.Key

  @type t() :: %__MODULE__{}

  defstruct [:name, :table, :prefix, columns: [], unique: false]

  def from_key(%Key{} = key) do
    table_name = key.model.table_name()
    column_names = Enum.map(key.fields, & &1.column_name)
    prefix = key.model.feature().name()

    from_opts(unique: key.unique?, columns: column_names, table: table_name, prefix: prefix)
  end

  def from_opts(opts) do
    __MODULE__
    |> struct(opts)
    |> with_name()
  end

  defp with_name(%__MODULE__{name: nil, columns: [_ | _]} = index) do
    name_parts = [index.table] ++ index.columns ++ ["idx"]
    name = name_parts |> Enum.join("_") |> String.to_atom()

    %{index | name: name}
  end

  defp with_name(index), do: index
end

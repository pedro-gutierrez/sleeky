defmodule Bee.Entity.Ecto do
  @moduledoc false
  import Bee.Inspector

  @generators [
    Bee.Entity.Ecto.FieldAttributes,
    Bee.Entity.Ecto.Schema,
    Bee.Entity.Ecto.Changesets,
    Bee.Entity.Ecto.FieldSpecs,
    Bee.Entity.Ecto.Slug
  ]

  def ast(entity) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, :binary_id, autogenerate: false}
      @timestamps_opts [type: :utc_datetime]

      unquote_splicing(
        @generators
        |> Enum.map(& &1.ast(entity))
        |> flatten()
      )
    end
  end
end

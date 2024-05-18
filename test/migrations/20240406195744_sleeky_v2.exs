defmodule Sleeky.Migration.V2 do
  use Ecto.Migration

  def up do
    alter(table(:posts, prefix: :publishing)) do
      modify(:published_at, :utc_datetime, null: true)
    end
  end

  def down do
    []
  end
end

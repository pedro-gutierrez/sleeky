defmodule Sleeky.Migration.V3 do
  use Ecto.Migration

  def up do
    alter(table(:posts, prefix: :publishing)) do
      add(:locked, :boolean, null: false)
    end
  end

  def down do
    []
  end
end

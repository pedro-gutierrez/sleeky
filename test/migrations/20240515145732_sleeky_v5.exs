defmodule Sleeky.Migration.V5 do
  use Ecto.Migration

  def up do
    alter(table(:blogs, prefix: :publishing)) do
      add(:published, :boolean, null: false)
    end

    alter(table(:posts, prefix: :publishing)) do
      add(:deleted, :boolean, null: false)
      add(:published, :boolean, null: false)
    end
  end

  def down do
    []
  end
end
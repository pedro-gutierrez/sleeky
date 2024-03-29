defmodule Sleeky.Migration.V4 do
  use Ecto.Migration

  def up do
    alter(table(:users, prefix: :accounts)) do
      add(:public, :boolean, null: false)
    end
  end

  def down do
    []
  end
end
defmodule Sleeky.Migration.V7 do
  use Ecto.Migration

  def up do
    alter(table(:users, prefix: :accounts)) do
      add(:external_id, :binary_id, null: false)
    end
  end

  def down do
    []
  end
end

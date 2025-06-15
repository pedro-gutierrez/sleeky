defmodule Sleeky.Migration.V4 do
  use Ecto.Migration

  def up do
    alter(table(:authors, prefix: :publishing)) do
      add(:profile, :string, null: false)
    end
  end

  def down do
    []
  end
end

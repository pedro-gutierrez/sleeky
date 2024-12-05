defmodule Sleeky.Migration.V2 do
  use Ecto.Migration

  def up do
    alter(table(:blogs, prefix: :publishing)) do
      add(:public, :boolean, null: true)
    end
  end

  def down do
    []
  end
end

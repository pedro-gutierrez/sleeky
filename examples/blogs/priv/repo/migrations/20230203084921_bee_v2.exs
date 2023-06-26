defmodule Bee.Migration.V2 do
  use Ecto.Migration

  def up do
    create(table(:countries, primary_key: false)) do
      add(:code, :string, [])
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      timestamps()
    end
  end

  def down do
    []
  end
end
defmodule Sleeky.Migration.V9 do
  use Ecto.Migration

  def up do
    create(table(:onboardings, prefix: :accounts, primary_key: false)) do
      add(:id, :binary_id, primary_key: true, null: false)
      add(:user_id, :binary_id, null: false)
      add(:steps_pending, :integer, null: false)
      timestamps(type: :utc_datetime_usec)
    end
  end

  def down do
    []
  end
end
defmodule Sleeky.Migration.V11 do
  use Ecto.Migration

  def up do
    create(table(:credentials, prefix: :accounts, primary_key: false)) do
      add(:enabled, :boolean, null: false)
      add(:id, :binary_id, primary_key: true, null: false)
      add(:name, :string, null: false)
      add(:value, :string, null: false)
      add(:user_id, :binary_id, null: false)
      timestamps(type: :utc_datetime_usec)
    end

    alter(table(:credentials, prefix: :accounts)) do
      modify(:user_id, references(:users, type: :binary_id, on_delete: :nothing))
    end

    create(
      unique_index(:credentials, [:user_id, :name],
        name: :credentials_user_id_name_idx,
        prefix: :accounts
      )
    )
  end

  def down do
    []
  end
end
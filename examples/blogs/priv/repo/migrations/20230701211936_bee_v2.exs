defmodule Bee.Migration.V2 do
  use Ecto.Migration

  def up do
    create(table(:credentials, primary_key: false)) do
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:public_key, :string, [])
      add(:user_id, :uuid, [])
      timestamps()
    end

    create(table(:logins, primary_key: false)) do
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:username, :string, [])
      timestamps()
    end

    create(table(:registrations, primary_key: false)) do
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:username, :string, [])
      timestamps()
    end

    alter(table(:credentials)) do
      modify(:user_id, references(:users, type: :uuid, null: false, on_delete: :nothing))
    end
  end

  def down do
    []
  end
end
defmodule Sleeky.Migration.V3 do
  use Ecto.Migration

  def up do
    create(unique_index(:users, [:email], name: :users_email_idx, prefix: :accounts))
  end

  def down do
    []
  end
end
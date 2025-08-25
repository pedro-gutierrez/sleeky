defmodule Sleeky.Migration.V10 do
  use Ecto.Migration

  def up do
    create(
      unique_index(:onboardings, [:user_id], name: :onboardings_user_id_idx, prefix: :accounts)
    )
  end

  def down do
    []
  end
end
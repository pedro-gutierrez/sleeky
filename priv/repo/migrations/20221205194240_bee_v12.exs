defmodule(Bee.Migration.V12) do
  use(Ecto.Migration)

  def(up) do
    alter(table(:users)) do
      add(:app, :string, null: false)
    end

    create(unique_index(:users, [:email, :app], name: :users_email_app_idx))
  end

  def(down) do
    []
  end
end
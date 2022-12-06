defmodule(Bee.Migration.V14) do
  use(Ecto.Migration)

  def(up) do
    execute("create type sentiment as ENUM ('positve','negative')")

    alter(table(:comments)) do
      add(:sentiment, :sentiment, null: false)
    end

    drop_if_exists(index(:users, [], name: :users_email_app_idx))
  end

  def(down) do
    []
  end
end
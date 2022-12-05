defmodule(Bee.Migration.V15) do
  use(Ecto.Migration)

  def(up) do
    create(unique_index(:users, [:email, :app], name: :users_email_app_idx))
  end

  def(down) do
    []
  end
end
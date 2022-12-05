defmodule(Bee.Migration.V16) do
  use(Ecto.Migration)

  def(up) do
    drop_if_exists(index(:users, :users_email_app_idx))
  end

  def(down) do
    []
  end
end
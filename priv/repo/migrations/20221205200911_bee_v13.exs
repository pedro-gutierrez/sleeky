defmodule(Bee.Migration.V13) do
  use(Ecto.Migration)

  def(up) do
    drop_if_exists(index(:users, :email))
    drop_if_exists(index(:posts, :slug))
  end

  def(down) do
    []
  end
end
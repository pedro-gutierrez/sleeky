defmodule(Bee.Migration.V15) do
  use(Ecto.Migration)

  def(up) do
    drop_if_exists(index(:users, [], name: :email))
    drop_if_exists(index(:posts, [], name: :slug))
  end

  def(down) do
    []
  end
end
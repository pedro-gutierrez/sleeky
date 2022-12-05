defmodule(Bee.Migration.V10) do
  use(Ecto.Migration)

  def(up) do
    create(unique_index(:users, [:email], name: :email))
    create(unique_index(:posts, [:slug], name: :slug))
  end

  def(down) do
    []
  end
end
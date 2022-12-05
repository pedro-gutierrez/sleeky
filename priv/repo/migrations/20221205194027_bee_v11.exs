defmodule(Bee.Migration.V11) do
  use(Ecto.Migration)

  def(up) do
    create(unique_index(:posts, [:slug], name: :posts_slug_idx))
    create(unique_index(:users, [:email], name: :users_email_idx))
  end

  def(down) do
    []
  end
end
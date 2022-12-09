defmodule(Bee.Migration.V16) do
  use(Ecto.Migration)

  def(up) do
    create(index(:posts, [:user_id, :subject], name: :posts_user_id_subject_idx))
  end

  def(down) do
    []
  end
end
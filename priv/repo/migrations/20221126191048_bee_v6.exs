defmodule(Bee.Migration.V6) do
  use(Ecto.Migration)

  def(up) do
    drop_if_exists(constraint(:votes, :votes_comment_id_fkey))
  end

  def(down) do
    []
  end
end
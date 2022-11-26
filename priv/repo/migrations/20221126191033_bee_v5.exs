defmodule(Bee.Migration.V5) do
  use(Ecto.Migration)

  def(up) do
    alter(table(:votes)) do
      modify(:comment_id, references(:comments, type: :uuid, null: false, on_delete: :nothing))
    end
  end

  def(down) do
    []
  end
end
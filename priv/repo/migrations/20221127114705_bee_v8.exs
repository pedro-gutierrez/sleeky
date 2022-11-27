defmodule(Bee.Migration.V8) do
  use(Ecto.Migration)

  def(up) do
    alter(table(:posts)) do
      add(:body, :string, null: false)
    end
  end

  def(down) do
    []
  end
end
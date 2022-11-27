defmodule(Bee.Migration.V9) do
  use(Ecto.Migration)

  def(up) do
    alter(table(:posts)) do
      remove(:body)
    end
  end

  def(down) do
    []
  end
end
defmodule(Bee.Migration.V5) do
  use(Ecto.Migration)

  def(up) do
    create(table(:votes, primary_key: false)) do
    end
  end

  def(down) do
    []
  end
end
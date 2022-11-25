defmodule(Bee.Migration.V2) do
  use(Ecto.Migration)

  def(up) do
    drop_if_exists(table(:votes))
  end

  def(down) do
    []
  end
end
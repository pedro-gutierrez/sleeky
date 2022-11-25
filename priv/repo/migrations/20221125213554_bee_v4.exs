defmodule(Bee.Migration.V4) do
  use(Ecto.Migration)

  def(up) do
    drop_if_exists(table(:votes))
  end

  def(down) do
    []
  end
end
defmodule(Bee.Migration.V1) do
  use(Ecto.Migration)

  def(up) do
    create(table(:comments, primary_key: false)) do
    end

    create(table(:posts, primary_key: false)) do
    end

    create(table(:tags, primary_key: false)) do
    end

    create(table(:users, primary_key: false)) do
    end

    create(table(:votes, primary_key: false)) do
    end
  end

  def(down) do
    []
  end
end
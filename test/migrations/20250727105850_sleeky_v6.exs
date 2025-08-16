defmodule Sleeky.Migration.V6 do
  use Ecto.Migration

  def up do
    alter(table(:users, prefix: :accounts)) do
      modify(:public, :boolean, default: false)
    end

    alter(table(:blogs, prefix: :publishing)) do
      modify(:public, :boolean, default: false)
      modify(:published, :boolean, default: false)
    end

    alter(table(:posts, prefix: :publishing)) do
      modify(:published, :boolean, default: false)
      modify(:locked, :boolean, default: false)
      modify(:deleted, :boolean, default: false)
    end
  end

  def down do
    []
  end
end

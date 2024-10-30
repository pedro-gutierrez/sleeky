defmodule Sleeky.Migration.V5 do
  use Ecto.Migration

  def up do
    alter(table(:users, prefix: :accounts)) do
      modify(:public, :boolean, [])
    end

    alter(table(:blogs, prefix: :publishing)) do
      modify(:public, :boolean, [])
      modify(:published, :boolean, [])
    end

    alter(table(:authors, prefix: :publishing)) do
      modify(:profile, :string, default: "publisher")
    end

    alter(table(:posts, prefix: :publishing)) do
      modify(:published, :boolean, [])
      modify(:deleted, :boolean, [])
      modify(:locked, :boolean, [])
    end
  end

  def down do
    []
  end
end
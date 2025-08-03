defmodule Sleeky.Migrations.DropTableTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "drop tables when entities are removed from contexts" do
      existing = [
        """
        defmodule Sleeky.Migration.V1 do
          use Ecto.Migration

          def up do
            create table(:emails, prefix: :notifications, primary_key: false) do
            end
          end
        end
        """
      ]

      migrations = generate_migrations(existing)
      assert migrations =~ "drop_if_exists(table(:emails, prefix: :notifications"
    end
  end
end

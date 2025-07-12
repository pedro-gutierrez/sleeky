defmodule Sleeky.Migrations.DropSchemaTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "drops schemas for obsolete domains" do
      existing = [
        """
        defmodule Sleeky.Migration.V1 do
          use Ecto.Migration

          def up do
            execute("CREATE SCHEMA monitoring")
          end
        end
        """
      ]

      migration = generate_migrations(existing)
      assert migration =~ "execute(\"DROP SCHEMA monitoring\")"
    end
  end
end

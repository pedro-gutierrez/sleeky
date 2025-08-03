defmodule Sleeky.Migrations.CreateSchemaTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "create schemas for new features" do
      migration = generate_migrations()
      assert migration =~ "execute(\"CREATE SCHEMA accounts\")"
    end
  end
end

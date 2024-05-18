defmodule Sleeky.Migrations.PrimaryKeyTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "generate primary key columns" do
      migration = generate_migrations()
      assert migration =~ "add(:id, :binary_id, primary_key: true, null: false)"
    end
  end
end

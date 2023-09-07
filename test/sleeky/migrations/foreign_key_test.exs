defmodule Sleeky.Migrations.ForeignKeyTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "generate foreign key columns" do
      migration = generate_migrations()
      assert migration =~ "add(:blog_id, :string, null: false)"
      assert migration =~ "add(:author_id, :binary_id, null: false)"
    end
  end
end

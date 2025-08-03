defmodule Sleeky.Migrations.CreateIndexTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "create indexes out of entity keys" do
      migration = generate_migrations()

      assert migration =~
               "create(\n      unique_index(:blogs, [:author_id, :name],\n        name: :blogs_author_id_name_idx,\n        prefix: :publishing\n"

      assert migration =~
               "create(unique_index(:themes, [:name], name: :themes_name_idx, prefix: :publishing))"
    end
  end
end

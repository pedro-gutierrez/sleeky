defmodule Sleeky.Migrations.VirtualEntityTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "do not generate tables for virtual entities" do
      migration = generate_migrations()
      refute migration =~ "digest"
    end
  end
end

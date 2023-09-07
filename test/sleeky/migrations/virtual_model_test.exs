defmodule Sleeky.Migrations.VirtualModelTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "do not generate tables for virtual models" do
      migration = generate_migrations()
      refute migration =~ "digest"
    end
  end
end

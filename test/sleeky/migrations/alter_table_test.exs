defmodule Sleeky.Migrations.AlterTableTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "add columns to existing tables" do
      [
        """
        defmodule Sleeky.Migration.V1 do
          use Ecto.Migration

          def up do
            create table(:topics, prefix: :publishing, primary_key: false) do
            end
          end
        end
        """
      ]
      |> generate_migrations()
      |> assert_migrations([
        "alter(table(:topics, prefix: :publishing)) do",
        "add(:id, :integer, primary_key: true, null: false)",
        "add(:name, :string, null: false)"
      ])
    end

    test "drops columns from existing tables" do
      [
        """
        defmodule Sleeky.Migration.V1 do
          use Ecto.Migration

          def up do
            create table(:topics, prefix: :publishing, primary_key: false) do
              add(:id, :integer, primary_key: true, null: false)
              add(:name, :string, null: false)
              add(:closed, :boolean, null: true)
            end
          end
        end
        """
      ]
      |> generate_migrations()
      |> assert_migrations([
        "alter(table(:topics, prefix: :publishing)) do",
        "remove(:closed)"
      ])
    end

    test "does not add columns that exist already" do
      [
        """
        defmodule Sleeky.Migration.V1 do
          use Ecto.Migration

          def up do
            create(table(:topics, prefix: :publishing, primary_key: false)) do
            end
            alter(table(:topics, prefix: :publishing)) do
              add(:id, :integer, primary_key: true, null: false)
              add(:name, :string, null: false)
            end
          end
        end
        """
      ]
      |> generate_migrations()
      |> refute_migrations([
        "alter(table(:topics, prefix: :publishing)) do"
      ])
    end
  end
end

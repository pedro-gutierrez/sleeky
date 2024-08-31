defmodule Sleeky.Migrations.CreateConstraintTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "don't create constraints that already exist" do
      [
        """
        defmodule Sleeky.Migration.V1 do
          use Ecto.Migration

          def up do
            create(table(:blogs, prefix: :publishing, primary_key: false)) do
              add(:author_id, :binary_id, null: false)
            end
            create(table(:authors, prefix: :publishing, primary_key: false)) do
            end

            alter(table(:blogs, prefix: :publishing)) do
              modify(:author_id, references(:authors, type: :binary_id, on_delete: :nothing))
            end
          end
        end
        """
      ]
      |> generate_migrations()
      |> refute_migrations([
        "alter(table(:blogs, prefix: :publishing)) do",
        "modify(:author_id, references(:authors, type: :binary_id, on_delete: :nothing))"
      ])
    end
  end
end

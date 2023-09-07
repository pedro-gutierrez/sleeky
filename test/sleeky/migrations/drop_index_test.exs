defmodule Sleeky.Migrations.DropIndexTest do
  use ExUnit.Case
  import MigrationHelper

  describe "migrations" do
    test "drop indexes that are no longer needed" do
      [
        """
        defmodule Sleeky.Migration.V1 do
          use Ecto.Migration

          def up do
            create(index(:blogs, [:id, :name], name: :blogs_id_name_idx, prefix: :publishing))
          end
        end
        """
      ]
      |> generate_migrations()
      |> assert_migrations([
        "drop_if_exists(index(:blogs, [], name: :blogs_id_name_idx, prefix: :publishing))"
      ])
    end

    test "do not drop indexes that were already dropped" do
      [
        """
        defmodule Sleeky.Migration.V1 do
          use Ecto.Migration

          def up do
            create(index(:blogs, [:id, :name], name: :blogs_id_name_idx, prefix: :publishing))
            drop_if_exists(index(:blogs, [], name: :blogs_id_name_idx, prefix: :publishing))
          end
        end
        """
      ]
      |> generate_migrations()
      |> refute_migrations([
        "drop_if_exists(index(:blogs, [], name: :blogs_id_name_idx, prefix: :publishing))"
      ])
    end
  end
end

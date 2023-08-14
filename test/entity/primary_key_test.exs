defmodule Sleeky.Entity.PrimaryKeyTest do
  use ExUnit.Case

  describe "entity primary keys" do
    test "are uuids by default" do
      defmodule E1 do
        use Sleeky.Entity

        attribute(:name, :string)
      end

      pk = E1.primary_key()
      assert :id == pk.field
      assert :id == pk.kind
      assert :binary_id == pk.storage
    end

    test "can also be integers" do
      defmodule E2 do
        use Sleeky.Entity

        attribute :id, :integer do
          primary_key()
        end

        attribute(:name, :string)
      end

      pk = E2.primary_key()
      assert :id == pk.field
      assert :integer == pk.kind
      assert :integer == pk.storage
    end

    test "can have a custom name" do
      defmodule E3 do
        use Sleeky.Entity

        attribute :name, :string do
          primary_key()
        end
      end

      pk = E3.primary_key()
      assert :name == pk.field
      assert :string == pk.kind
      assert :string == pk.storage
    end
  end
end

defmodule Sleeky.Model.RelationTest do
  use ExUnit.Case

  alias Blogs.Publishing.Blog
  alias Sleeky.Model.Relation

  describe "models" do
    test "have parent relations" do
      for rel <- Blog.parents() do
        assert {:ok, %Relation{} = ^rel} = Blog.field(rel.name)
      end
    end
  end
end

defmodule Sleeky.Context.PathsTest do
  use ExUnit.Case

  alias Blogs.Publishing

  describe "context" do
    test "evaluates the shortest path between two models" do
      assert [:author] == Publishing.shortest_path(:comment, :author)
    end

    test "all paths between an model and an ancetor" do
      assert [[:author], [:post, :blog, :author]] == Publishing.paths(:comment, :author)
    end
  end
end

defmodule Sleeky.Context.PathsTest do
  use ExUnit.Case

  alias Blogs.Publishing

  describe "shortest_path/2" do
    test "evaluates the shortest to an attribute" do
      assert [:body] == Publishing.get_shortest_path(:comment, :body)
    end

    test "evaluates the shortest to an ancestor" do
      assert [:author] == Publishing.get_shortest_path(:comment, :author)
    end

    test "evaluates the shortest to an attribute in a parent" do
      assert [:post, :locked] == Publishing.get_shortest_path(:comment, :locked)
    end

    test "evaluates the shortest to an attribute in an ancestor" do
      assert [:post, :blog, :public] == Publishing.get_shortest_path(:comment, :public)
    end
  end

  describe "paths/2" do
    test "returns all paths between an model and an ancestor" do
      assert [[:author], [:post, :author], [:post, :blog, :author]] ==
               Publishing.get_paths(:comment, :author)
    end
  end
end

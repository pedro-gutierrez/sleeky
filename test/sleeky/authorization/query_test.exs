defmodule Sleeky.Authorization.QueryTest do
  use ExUnit.Case

  alias Sleeky.Authorization.{Expression, Query, Scope}
  alias Blogs.Publishing.{Blog, Post}

  import Ecto.Query

  @query from(p in Post, as: :post)

  describe "scope/4" do
    test "does basic filtering" do
      scope = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:published]},
            {:value, true}
          ]
        }
      }

      params = %{}

      Query.scope(Post, @query, scope, params)
    end
  end

  describe "query_builder/4" do
    test "supports simple filtering" do
      published = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:published]},
            {:value, true}
          ]
        }
      }

      builder = Query.build(Post, published)

      assert builder.filters == [{{:post, :published}, :eq, true}]
    end

    test "supports wildcard filtering on attributes" do
      published = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:**, :published]},
            {:value, true}
          ]
        }
      }

      builder = Query.build(Post, published)

      assert builder.filters == [{{:post, :published}, :eq, true}]
    end

    for {combinator, operation} <- [all: :and, one: :or] do
      test "support combinations of simple filters using #{combinator}" do
        published = %Scope{
          expression: %Expression{
            op: :eq,
            args: [
              {:path, [:published]},
              {:value, true}
            ]
          }
        }

        locked = %Scope{
          expression: %Expression{
            op: :eq,
            args: [
              {:path, [:locked]},
              {:value, true}
            ]
          }
        }

        combined = %Scope{
          expression: %Expression{
            op: unquote(combinator),
            args: [published, locked]
          }
        }

        builder = Query.build(Post, combined)

        assert builder.filters == [
                 {unquote(operation),
                  [
                    {{:post, :published}, :eq, true},
                    {{:post, :locked}, :eq, true}
                  ]}
               ]
      end
    end

    test "supports joining on parent" do
      blog_published = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:blog, :published]},
            {:value, true}
          ]
        }
      }

      builder = Query.build(Post, blog_published)

      assert builder.filters == [{{:blog, :published}, :eq, true}]

      assert builder.joins == [
               {:join, {Blogs.Publishing.Blog, :blog, :id}, {:post, :blog_id}}
             ]
    end

    test "supports joining on ancestor" do
      blog_published = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:blog, :author, :name]},
            {:value, "John"}
          ]
        }
      }

      builder = Query.build(Post, blog_published)

      assert builder.filters == [{{:author, :name}, :eq, "John"}]

      assert builder.joins == [
               {:join, {Blogs.Publishing.Blog, :blog, :id}, {:post, :blog_id}},
               {:join, {Blogs.Publishing.Author, :author, :id}, {:blog, :author_id}}
             ]
    end

    test "supports fitering on parent" do
      for_blog = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:blog]},
            {:value, %{id: 1}}
          ]
        }
      }

      builder = Query.build(Post, for_blog)

      assert builder.filters == [{{:post, :blog_id}, :eq, 1}]
    end

    test "supports filtering on child" do
      published_posts = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:posts]},
            {:value, 1}
          ]
        }
      }

      builder = Query.build(Blog, published_posts)

      assert builder.filters == [{{:posts, :id}, :eq, 1}]

      assert builder.joins == [
               {:join, {Blogs.Publishing.Post, :posts, :blog_id}, {:blog, :id}}
             ]
    end

    test "supports filtering on child attribute" do
      published_posts = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:posts, :published]},
            {:value, true}
          ]
        }
      }

      builder = Query.build(Blog, published_posts)

      assert builder.filters == [{{:posts, :published}, :eq, true}]

      assert builder.joins == [
               {:join, {Blogs.Publishing.Post, :posts, :blog_id}, {:blog, :id}}
             ]
    end
  end
end

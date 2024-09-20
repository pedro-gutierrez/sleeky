defmodule Sleeky.Authorization.QueryTest do
  use ExUnit.Case

  alias Sleeky.Authorization.{Expression, Query, Scope}
  alias Blogs.Publishing.{Blog, Post, Comment}

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

    test "supports deeply nested scopes" do
      published = scope(:eq, [{:path, [:published]}, {:value, true}])
      locked = scope(:eq, [{:path, [:locked]}, {:value, true}])

      combined =
        scope(
          :all,
          [
            published,
            scope(:one, [published, scope(:all, [published, locked])]),
            scope(:one, [
              locked,
              scope(:all, [scope(:all, [published, locked, published, locked]), locked])
            ])
          ]
        )

      builder = Query.build(Post, combined)

      assert builder.filters == [
               and: [
                 {{:post, :published}, :eq, true},
                 {:or,
                  [
                    {{:post, :published}, :eq, true},
                    {:and, [{{:post, :published}, :eq, true}, {{:post, :locked}, :eq, true}]}
                  ]},
                 {:or,
                  [
                    {{:post, :locked}, :eq, true},
                    {:and,
                     [
                       {:and,
                        [
                          {{:post, :published}, :eq, true},
                          {{:post, :locked}, :eq, true},
                          {{:post, :published}, :eq, true},
                          {{:post, :locked}, :eq, true}
                        ]},
                       {{:post, :locked}, :eq, true}
                     ]}
                  ]}
               ]
             ]
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

      assert builder.joins == [
               {:join, {Blogs.Publishing.Blog, :post_blog, :id}, {:post, :blog_id}}
             ]

      assert builder.filters == [{{:post_blog, :published}, :eq, true}]
    end

    test "supports joining on optional parent" do
      blog_published = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:blog, :theme, :name]},
            {:value, "Science"}
          ]
        }
      }

      builder = Query.build(Post, blog_published)

      assert builder.joins == [
               {:join, {Blogs.Publishing.Blog, :post_blog, :id}, {:post, :blog_id}},
               {:left_join, {Blogs.Publishing.Theme, :post_blog_theme, :id},
                {:post_blog, :theme_id}}
             ]

      assert builder.filters == [{{:post_blog_theme, :name}, :eq, "Science"}]
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

      assert builder.joins == [
               {:join, {Blogs.Publishing.Blog, :post_blog, :id}, {:post, :blog_id}},
               {:join, {Blogs.Publishing.Author, :post_blog_author, :id},
                {:post_blog, :author_id}}
             ]

      assert builder.filters == [{{:post_blog_author, :name}, :eq, "John"}]
    end

    test "supports joining on parent and ancestor" do
      post_author = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:post, :author, :name]},
            {:value, "John"}
          ]
        }
      }

      blog_author = %Scope{
        expression: %Expression{
          op: :eq,
          args: [
            {:path, [:post, :blog, :author, :name]},
            {:value, "John"}
          ]
        }
      }

      combined = %Scope{
        expression: %Expression{
          op: :one,
          args: [post_author, blog_author]
        }
      }

      builder = Query.build(Comment, combined)

      assert builder.joins == [
               {:join, {Blogs.Publishing.Post, :comment_post, :id}, {:comment, :post_id}},
               {:join, {Blogs.Publishing.Author, :comment_post_author, :id},
                {:comment_post, :author_id}},
               {:join, {Blogs.Publishing.Blog, :comment_post_blog, :id},
                {:comment_post, :blog_id}},
               {:join, {Blogs.Publishing.Author, :comment_post_blog_author, :id},
                {:comment_post_blog, :author_id}}
             ]

      assert builder.filters ==
               [
                 or: [
                   {{:comment_post_author, :name}, :eq, "John"},
                   {{:comment_post_blog_author, :name}, :eq, "John"}
                 ]
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

      assert builder.joins == [
               {:left_join, {Blogs.Publishing.Post, :blog_posts, :blog_id}, {:blog, :id}}
             ]

      assert builder.filters == [{{:blog_posts, :id}, :eq, 1}]
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

      assert builder.joins == [
               {:left_join, {Blogs.Publishing.Post, :blog_posts, :blog_id}, {:blog, :id}}
             ]

      assert builder.filters == [{{:blog_posts, :published}, :eq, true}]
    end
  end

  defp scope(op, args) do
    %Scope{
      expression: %Expression{
        op: op,
        args: args
      }
    }
  end
end

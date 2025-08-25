defmodule Sleeky.ScopeTest do
  use ExUnit.Case

  alias Blogs.Accounts.Scopes.SelfAndNotLocked
  alias Blogs.Publishing.{Blog, Post, Comment, Author}

  alias Sleeky.Scope
  alias Sleeky.Scope.Expression

  defmodule Simple do
    use Sleeky.Scope

    scope do
      same do
        path "published"
        true
      end
    end
  end

  defmodule IsPublishedWildcard do
    use Sleeky.Scope

    scope do
      same do
        path "**.published"
        true
      end
    end
  end

  defmodule IsPublished do
    use Sleeky.Scope

    scope do
      is_true do
        path "published"
      end
    end
  end

  defmodule IsLocked do
    use Sleeky.Scope

    scope do
      is_true do
        path "locked"
      end
    end
  end

  defmodule IsPublishedAndIsLocked do
    use Sleeky.Scope

    scope do
      all do
        IsPublished
        IsLocked
      end
    end
  end

  defmodule IsPublishedAndIsLockedOrIsPublished do
    use Sleeky.Scope

    scope do
      one do
        all do
          IsPublished
          IsLocked
        end

        IsPublished
      end
    end
  end

  describe "allowed?/1" do
    test "returns true when all sub scopes are verified, and the operation is all" do
      context = %{current_user: %{id: 1}, user: %{id: 1, locked: false}}

      assert SelfAndNotLocked.allowed?(context)
    end

    test "returns false when some sub scopes is not verified, and the operation is all" do
      context = %{current_user: %{id: 1}, user: %{id: 1, locked: true}}

      refute SelfAndNotLocked.allowed?(context)
    end
  end

  @is_published_expr %Expression{op: :eq, args: [path: [:published], value: true]}
  @is_locked_expr %Expression{op: :eq, args: [path: [:locked], value: true]}

  describe "expression/0" do
    test "resolves simple arguments" do
      assert %Expression{
               args: [path: [:published], value: true],
               op: :eq
             } == IsPublished.expression()
    end

    test "resolves nested scopes" do
      assert %Expression{
               args: [@is_published_expr, @is_locked_expr],
               op: :all
             } == IsPublishedAndIsLocked.expression()
    end

    test "supports nested combinators" do
      assert %Expression{
               args: [
                 %Expression{
                   args: [@is_published_expr, @is_locked_expr],
                   op: :all
                 },
                 @is_published_expr
               ],
               op: :one
             } == IsPublishedAndIsLockedOrIsPublished.expression()
    end
  end

  describe "query_builder/3" do
    test "supports simple filtering" do
      builder = Scope.query_builder(Post, Simple)

      assert builder.filters == [{{:post, :published}, :eq, true}]
    end
  end

  test "supports wildcard filtering on attributes" do
    builder = Scope.query_builder(Post, IsPublishedWildcard)

    assert builder.filters == [{{:post, :published}, :eq, true}]
  end

  test "combines filter using the 'and' operator" do
    builder = Scope.query_builder(Post, IsPublishedAndIsLocked)

    assert builder.filters == [
             {:and,
              [
                {{:post, :published}, :eq, true},
                {{:post, :locked}, :eq, true}
              ]}
           ]
  end

  test "combines filter using the 'or' operator" do
    defmodule IsPublishedOrIsLocked do
      use Sleeky.Scope

      scope do
        all do
          IsPublished
          IsLocked
        end
      end
    end

    builder = Scope.query_builder(Post, IsPublishedOrIsLocked)

    assert builder.filters == [
             {:and,
              [
                {{:post, :published}, :eq, true},
                {{:post, :locked}, :eq, true}
              ]}
           ]
  end

  test "supports deeply nested scopes" do
    defmodule DeeplyNested do
      use Sleeky.Scope

      scope do
        all do
          IsPublished

          one do
            IsPublished

            all do
              IsPublished
              IsLocked
            end
          end

          one do
            IsLocked

            all do
              all do
                IsPublished
                IsLocked
                IsPublished
                IsLocked
              end

              IsLocked
            end
          end
        end
      end
    end

    builder = Scope.query_builder(Post, DeeplyNested)

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
    defmodule IsBlogPublished do
      use Sleeky.Scope

      scope do
        same do
          path "blog.published"
          true
        end
      end
    end

    builder = Scope.query_builder(Post, IsBlogPublished)

    assert builder.joins == [
             {:join, {Blogs.Publishing.Blog, :post_blog, :id}, {:post, :blog_id}}
           ]

    assert builder.filters == [{{:post_blog, :published}, :eq, true}]
  end

  test "supports joining on optional parent" do
    defmodule IsScienceBlog do
      use Sleeky.Scope

      scope do
        same do
          path "blog.theme.name"
          "Science"
        end
      end
    end

    builder = Scope.query_builder(Post, IsScienceBlog)

    assert builder.joins == [
             {:join, {Blog, :post_blog, :id}, {:post, :blog_id}},
             {:left_join, {Blogs.Publishing.Theme, :post_blog_theme, :id},
              {:post_blog, :theme_id}}
           ]

    assert builder.filters == [{{:post_blog_theme, :name}, :eq, "Science"}]
  end

  test "supports joining on ancestor" do
    defmodule IsBlogAuthorJohn do
      use Sleeky.Scope

      scope do
        same do
          path "blog.author.name"
          "John"
        end
      end
    end

    builder = Scope.query_builder(Post, IsBlogAuthorJohn)

    assert builder.joins == [
             {:join, {Blog, :post_blog, :id}, {:post, :blog_id}},
             {:join, {Author, :post_blog_author, :id}, {:post_blog, :author_id}}
           ]

    assert builder.filters == [{{:post_blog_author, :name}, :eq, "John"}]
  end

  test "supports joining on parent and ancestor" do
    defmodule IsPostAuthorJohn do
      use Sleeky.Scope

      scope do
        same do
          path "post.author.name"
          "John"
        end
      end
    end

    defmodule IsPostBlogAuthorJohn do
      use Sleeky.Scope

      scope do
        same do
          path "post.blog.author.name"
          "John"
        end
      end
    end

    defmodule IsPostOrBlogAuthorJohn do
      use Sleeky.Scope

      scope do
        one do
          IsPostAuthorJohn
          IsPostBlogAuthorJohn
        end
      end
    end

    builder = Scope.query_builder(Comment, IsPostOrBlogAuthorJohn)

    assert builder.joins == [
             {:join, {Post, :comment_post, :id}, {:comment, :post_id}},
             {:join, {Author, :comment_post_author, :id}, {:comment_post, :author_id}},
             {:join, {Blog, :comment_post_blog, :id}, {:comment_post, :blog_id}},
             {:join, {Author, :comment_post_blog_author, :id}, {:comment_post_blog, :author_id}}
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
    defmodule IsBlogOne do
      use Sleeky.Scope

      scope do
        same do
          path "blog"
          1
        end
      end
    end

    builder = Scope.query_builder(Post, IsBlogOne)
    assert builder.filters == [{{:post, :blog_id}, :eq, 1}]
  end

  test "supports filtering on child" do
    defmodule HasPostOne do
      use Sleeky.Scope

      scope do
        same do
          path "posts"
          1
        end
      end
    end

    builder = Scope.query_builder(Blog, HasPostOne)

    assert builder.joins == [
             {:left_join, {Post, :blog_posts, :blog_id}, {:blog, :id}}
           ]

    assert builder.filters == [{{:blog_posts, :id}, :eq, 1}]
  end

  test "supports filtering on child attribute" do
    defmodule PublishedPosts do
      use Sleeky.Scope

      scope do
        same do
          path "posts.published"
          true
        end
      end
    end

    builder = Scope.query_builder(Blog, PublishedPosts)

    assert builder.joins == [
             {:left_join, {Post, :blog_posts, :blog_id}, {:blog, :id}}
           ]

    assert builder.filters == [{{:blog_posts, :published}, :eq, true}]
  end
end

defmodule Sleeky.QueryBuilderTest do
  use Sleeky.DataCase

  alias Sleeky.QueryBuilder

  alias Blogs.Publishing.{Author, Blog, Post}

  import Ecto.Query

  @query from(p in Post, as: :post)

  @select "SELECT p0.\"id\", p0.\"title\", p0.\"published_at\", p0.\"locked\", " <>
            "p0.\"published\", p0.\"deleted\", p0.\"blog_id\", p0.\"author_id\", p0.\"inserted_at\", " <>
            "p0.\"updated_at\" FROM \"publishing\".\"posts\" AS p0"

  test "supports no filters" do
    sql =
      @query
      |> QueryBuilder.filter(nil)
      |> to_sql()

    assert sql == @select
  end

  test "combines filters with 'and' by default" do
    sql =
      @query
      |> QueryBuilder.filter([
        {{:post, :published}, :eq, true},
        {{:post, :locked}, :eq, true},
        {{:post, :deleted}, :eq, true}
      ])
      |> to_sql()

    assert sql ==
             @select <>
               " WHERE (((p0.\"published\" = $1) AND (p0.\"locked\" = $2)) AND (p0.\"deleted\" = $3))"
  end

  test "translates filters on lists into the in operator" do
    sql =
      @query
      |> QueryBuilder.filter([
        {{:post, :published}, :eq, [true, false]}
      ])
      |> to_sql()

    assert sql =~ " WHERE (p0.\"published\" = ANY($1)"
  end

  test "supports soring" do
    sql =
      @query
      |> QueryBuilder.sort([
        {{:post, :id}, :asc},
        {{:post, :inserted}, :desc}
      ])
      |> to_sql()

    assert sql =~ "ORDER BY p0.\"id\", p0.\"inserted\" DESC"
  end

  test "also works without aliases" do
    sql =
      Post
      |> QueryBuilder.filter([
        {:published, :eq, true},
        {:locked, :eq, true},
        {:deleted, :eq, true}
      ])
      |> QueryBuilder.sort([
        {:id, :asc},
        {:inserted, :desc}
      ])
      |> to_sql()

    assert sql ==
             "SELECT p0.\"id\", p0.\"title\", p0.\"published_at\", p0.\"locked\", p0.\"published\", p0.\"deleted\", p0.\"blog_id\", p0.\"author_id\", p0.\"inserted_at\", p0.\"updated_at\" FROM \"publishing\".\"posts\" AS p0 WHERE (((p0.\"published\" = $1) AND (p0.\"locked\" = $2)) AND (p0.\"deleted\" = $3)) ORDER BY p0.\"id\", p0.\"inserted\" DESC"
  end

  test "combines 'and' and 'or'" do
    sql =
      @query
      |> QueryBuilder.filter([
        {{:post, :published}, :eq, true},
        {:or,
         [
           {{:post, :locked}, :eq, true},
           {{:post, :deleted}, :eq, true}
         ]}
      ])
      |> to_sql()

    assert sql ==
             @select <>
               " WHERE ((p0.\"published\" = $1) AND ((p0.\"locked\" = $2) OR (p0.\"deleted\" = $3)))"
  end

  test "combines with 'or' at the top level, if specified" do
    sql =
      @query
      |> QueryBuilder.filter(
        {:or,
         [
           {{:post, :locked}, :eq, true},
           {{:post, :deleted}, :eq, true}
         ]}
      )
      |> to_sql()

    assert sql == @select <> " WHERE ((p0.\"locked\" = $1) OR (p0.\"deleted\" = $2))"
  end

  test "combines complex nested and and or expressions" do
    a = {{:post, :locked}, :eq, true}
    b = {{:post, :deleted}, :eq, true}

    sql =
      @query
      |> QueryBuilder.filter(
        {:and,
         [
           {:or, [a, b]},
           {:or,
            [
              {:and, [a, b]},
              {:and, [a, b]}
            ]}
         ]}
      )
      |> to_sql()

    assert sql ==
             @select <>
               " WHERE (((p0.\"locked\" = $1) OR (p0.\"deleted\" = $2)) " <>
               "AND (((p0.\"locked\" = $3) AND (p0.\"deleted\" = $4)) " <>
               "OR ((p0.\"locked\" = $5) AND (p0.\"deleted\" = $6))))"
  end

  test "supports joins" do
    sql =
      @query
      |> QueryBuilder.join([
        {:join, {Blog, :blog, :id}, {:post, :blog_id}},
        {:join, {Author, :author, :id}, {:blog, :author_id}}
      ])
      |> to_sql()

    assert sql ==
             @select <>
               " INNER JOIN \"publishing\".\"blogs\" AS b1 ON p0.\"blog_id\" = b1.\"id\"" <>
               " INNER JOIN \"publishing\".\"authors\" AS a2 ON b1.\"author_id\" = a2.\"id\""
  end

  test "supports left joins" do
    sql =
      @query
      |> QueryBuilder.join([
        {:left_join, {Blog, :blog, :id}, {:post, :blog_id}},
        {:left_join, {Author, :author, :id}, {:blog, :author_id}}
      ])
      |> to_sql()

    assert sql ==
             @select <>
               " LEFT OUTER JOIN \"publishing\".\"blogs\" AS b1 ON p0.\"blog_id\" = b1.\"id\"" <>
               " LEFT OUTER JOIN \"publishing\".\"authors\" AS a2 ON b1.\"author_id\" = a2.\"id\""
  end
end

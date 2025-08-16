defmodule Sleeky.SqlHelper do
  @moduledoc false
  import ExUnit.Assertions

  @doc """
  Convert the given givne into its generated sql
  """
  def to_sql(query, repo) do
    {sql, _params} = repo.to_sql(:all, query)

    sql
  end

  @doc """
  Asserts that the given query matches the given string
  """
  def assert_sql(sql, fragments) do
    for fragment <- fragments do
      assert sql =~ fragment
    end

    sql
  end

  @doc """
  Asserts that the given query does not match the given string
  """
  def refute_sql(sql, fragments) do
    for fragment <- fragments do
      refute sql =~ fragment
    end

    sql
  end
end

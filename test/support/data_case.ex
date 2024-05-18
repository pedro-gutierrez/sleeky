defmodule Sleeky.DataCase do
  @moduledoc false

  defmacro __using__(opts) do
    repo = :sleeky |> Application.fetch_env!(Sleeky) |> Keyword.fetch!(:repo)

    quote do
      @repo unquote(repo)

      use ExUnit.Case, unquote(opts)
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Sleeky.Fixtures

      alias Ecto.Adapters.SQL.Sandbox
      alias Ecto.Adapters.Postgres.Connection, as: SQL

      setup tags do
        Application.ensure_all_started(:sleeky)
        start_supervised!(@repo)

        pid = Sandbox.start_owner!(@repo, shared: not tags[:async])
        on_exit(fn -> Sandbox.stop_owner(pid) end)
        :ok
      end

      @doc """
      A helper that transforms changeset errors into a map of messages.

          assert {:error, changeset} = Accounts.create_user(%{password: "short"})
          assert "password is too short" in errors_on(changeset).password
          assert %{password: ["password is too short"]} = errors_on(changeset)

      """
      def errors_on(changeset) do
        Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
          Regex.replace(~r"%{(\w+)}", message, fn _, key ->
            opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
          end)
        end)
      end

      @doc """
      Convert the given givne into its generated sql
      """
      def to_sql(query) do
        {sql, _params} = @repo.to_sql(:all, query)
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
  end
end

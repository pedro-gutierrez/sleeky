defmodule Mix.Tasks.Sleeky.Gen.Migrations do
  @moduledoc """
  A Mix task that generates all Ecto migrations for your schema
  """

  use Mix.Task

  alias Sleeky.Migrations
  alias Sleeky.Migrations.Migration

  @shortdoc """
  A Mix task that generates all Ecto migrations for your schema
  """

  @requirements ["compile"]

  @impl true
  def run(_) do
    contexts = :sleeky |> Application.fetch_env!(Sleeky) |> Keyword.fetch!(:contexts)

    dir = Path.join([File.cwd!(), "priv/repo/migrations"])

    dir
    |> Migrations.existing()
    |> Migrations.missing(contexts)
    |> case do
      %{steps: []} ->
        Mix.shell().info("No migrations to write")

      m ->
        filename = Migration.filename(m)
        path = Path.join([dir, filename])
        data = m |> Migration.encode() |> Migration.format()
        File.write!(path, data)

        Mix.shell().info("Written #{path}")
    end
  end
end

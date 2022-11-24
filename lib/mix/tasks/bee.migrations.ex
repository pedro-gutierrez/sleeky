defmodule Mix.Tasks.Bee.Migrations do
  @moduledoc """
  A Mix task that generates all Ecto migrations for your schema
  """

  use Mix.Task

  alias Bee.Migrations
  alias Bee.Migrations.Migration

  @shortdoc """
  A Mix task that generates all Ecto migrations for your schema
  """

  @impl true
  def run([schema]) do
    schema = schema |> String.split(".") |> Module.concat()
    Code.ensure_compiled!(schema)

    dir = Path.join([File.cwd!(), "priv/repo/migrations"])

    dir
    |> Migrations.existing()
    |> Migrations.missing(schema)
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

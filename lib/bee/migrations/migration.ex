defmodule Bee.Migrations.Migration do
  @moduledoc false
  import Bee.Inspector
  import Bee.Migrations.Ecto

  @mutations [
    Bee.Migrations.CreateTable
  ]

  defstruct [
    :version,
    :ts,
    name: "bee",
    skip: false,
    steps: []
  ]

  def new(opts \\ []) do
    __MODULE__
    |> struct(opts)
    |> with_timestamp()
  end

  def with_timestamp(%{ts: nil} = migration) do
    {:ok, ts} =
      Calendar.DateTime.now_utc()
      |> Calendar.Strftime.strftime("%Y%m%d%H%M%S")

    Map.put_new(migration, :timestamp, ts)
  end

  def with_timestamp(migration), do: migration

  def with_version(migration, v) do
    %{migration | version: v}
  end

  def filename(m) do
    [m.timestamp, "_", m.name, "_v", m.version, ".exs"]
    |> Enum.map(&to_string/1)
    |> Enum.join("")
  end

  def format(code) do
    code
    |> Macro.to_string()
    |> Code.format_string!()
  end

  def encode(migration) do
    body =
      migration.steps
      |> Enum.reduce([], fn step, code ->
        code ++ [step.__struct__.encode(step)]
      end)
      |> flatten()

    migration(migration.version, body)
  end

  def decode(migration) do
    version = version(migration)
    steps = steps(migration)

    Enum.reduce(@mutations, new(version: version), fn mutation, m ->
      Enum.reduce(steps, m, fn step, m2 ->
        step
        |> mutation.decode()
        |> with_step(m2)
      end)
    end)
  end

  def aggregate(%{steps: steps}, state) do
    Enum.reduce(steps, state, & &1.__struct__.aggregate(&1, &2))
  end

  def diff(old, new, opts) do
    Enum.reduce(@mutations, new(opts), fn mutation, m ->
      old
      |> mutation.diff(new)
      |> flatten()
      |> Enum.reduce(m, &with_step/2)
    end)
  end

  def with_step(step, migration) do
    steps = migration.steps ++ [step]
    %{migration | steps: steps}
  end
end

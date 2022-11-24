defmodule Bee.Migrations.Migration do
  @moduledoc false
  import Bee.Inspector

  @mutations [
    Bee.Migrations.CreateTable
  ]

  defstruct [
    :version,
    :ts,
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
    [m.timestamp, "_v", m.version, ".exs"]
    |> Enum.map(&to_string/1)
    |> Enum.join("")
  end

  def format(code) do
    code
    |> Macro.to_string()
    |> Code.format_string!()
  end

  def encode(migration) do
    Enum.reduce(migration.steps, [], fn step, code ->
      code ++ step.__struct__.encode(migration)
    end)
    |> flatten()
  end

  def decode({:defmodule, _, [{:__aliases__, _, _}, [do: {:__block__, [], steps}]]}) do
    Enum.reduce(@mutations, new(), fn mutation, m ->
      Enum.reduce(steps, m, fn step, m2 ->
        mutation.decode(step, m2)
      end)
    end)
  end

  def into(%{steps: steps}, state) do
    Enum.reduce(steps, state, & &1.__struct__.into(&1, &2))
  end

  def diff(old, new, opts) do
    Enum.reduce(@mutations, new(opts), fn mutation, m ->
      mutation.diff(old, new, m)
    end)
  end

  def with_step(step, migration) do
    steps = migration.steps ++ [step]
    %{migration | steps: steps}
  end
end

defmodule Sleeky.Migrations.CreateEnum do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step

  alias Sleeky.Migrations.Step
  alias Sleeky.Database
  alias Sleeky.Database.State

  import Sleeky.Inspector

  defstruct [:enum]

  def new(enum) do
    %__MODULE__{enum: enum}
  end

  @impl Step
  def decode({:execute, _, ["create type " <> expr]}) do
    [name | values] =
      expr
      |> String.replace("as ENUM (", "")
      |> String.replace(")", "")
      |> String.replace("'", "")
      |> String.replace(",", " ")
      |> String.split(" ")

    name = String.to_atom(name)
    values = atoms(values)

    name
    |> Database.Enum.new(values)
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(%__MODULE__{enum: enum}) do
    values = Enum.map_join(enum.values, ",", &"'#{&1}'")

    {:execute, [line: 1], ["create type #{enum.name} as ENUM (#{values})"]}
  end

  @impl Step
  def aggregate(step, state) do
    State.add!(step.enum, :enums, state)
  end

  @impl Step
  def diff(old, new) do
    new.enums
    |> Map.values()
    |> Enum.reject(&State.has?(old, :enums, &1.name))
    |> Enum.map(&new/1)
  end
end

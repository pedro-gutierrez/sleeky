defmodule Sleeky.Migrations.DropEnum do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step

  alias Sleeky.Migrations.Step
  alias Sleeky.Database
  alias Sleeky.Database.State

  defstruct [:enum]

  def new(enum) do
    %__MODULE__{enum: enum}
  end

  @impl Step
  def decode({:execute, _, ["drop type " <> name]}) do
    name
    |> Database.Enum.new()
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(%__MODULE__{enum: enum}) do
    {:execute, [line: 1], ["drop type #{enum.name}"]}
  end

  @impl Step
  def aggregate(step, state) do
    State.remove!(step.enum, :enums, state)
  end

  @impl Step
  def diff(old, new) do
    old.enums
    |> Map.values()
    |> Enum.reject(&State.has?(new, :enums, &1.name))
    |> Enum.map(&new/1)
  end
end

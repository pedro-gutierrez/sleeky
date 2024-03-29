defmodule Sleeky.Compare.Eq do
  @moduledoc false

  def compare([%{id: id}, %{id: id}]), do: true
  def compare([id, %{id: id}]), do: true
  def compare([%{id: id}, id]), do: true
  def compare([a, a]), do: true
  def compare(_), do: false
end

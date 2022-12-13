defmodule Bee.Entity.Action do
  @moduledoc false

  alias Bee.Entity.Summary

  defstruct [
    :name,
    :entity,
    list?: false,
    custom?: false
  ]

  @built_in [:create, :list, :read, :update, :delete]

  def new(opts) do
    __MODULE__
    |> struct(opts)
    |> with_summary_entity()
    |> maybe_custom_action()
    |> maybe_list_action()
  end

  defp with_summary_entity(action) do
    %{action | entity: Summary.new(action.entity)}
  end

  defp maybe_custom_action(action) do
    %{action | custom?: !Enum.member?(@built_in, action.name)}
  end

  defp maybe_list_action(action) do
    %{action | list?: action.name |> to_string() |> String.starts_with?("list")}
  end
end

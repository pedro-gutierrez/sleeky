defmodule Sleeky.Ui.Composition do
  @moduledoc """
  Provides a Dsl to compose views
  """

  defmacro __using__(_opts) do
    quote do
      import Sleeky.Ui.Composition
    end
  end

  defmacro view(view) do
    {:insert_view, [line: 1], [view]}
  end

  defmacro view(view, do: {:__block__, _, content}) when is_list(content) do
    content = for {slot, _, content} <- content, do: {slot, unwrap(content)}
    {:insert_view, [line: 1], [view, content]}
  end

  defmacro view(view, do: {slot, _, [[do: content]]}) do
    {:insert_view, [line: 1], [view, {slot, content}]}
  end

  defmacro view(view, do: {slot, _, content}) do
    {:insert_view, [line: 1], [view, {slot, content}]}
  end

  defmacro slot(name) do
    {:insert_slot, [line: 1], [name]}
  end

  def insert_view(view) do
    {:view, view, []}
  end

  def insert_view(view, children) when is_list(children) do
    {:view, view, children}
  end

  def insert_view(view, child) do
    {:view, view, [child]}
  end

  def insert_slot(name), do: {:slot, [], [name]}

  def unwrap([[do: content]]), do: content
  def unwrap([content]), do: content
  def unwrap(content), do: content
end

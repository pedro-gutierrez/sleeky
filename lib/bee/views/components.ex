defmodule Bee.Views.Components do
  @moduledoc false

  def data(name), do: {"data-#{name}", ""}
  def data(name, value), do: {"data-#{name}", value}
  def scope(name), do: data(:scope, name)
  def mode(name), do: data(:mode, name)

  def title_view(title), do: {:h1, [], [title]}
  def link_view(url, child), do: {:a, [data(:link, url)], [child]}
  def label_view(title), do: {:label, [], [title]}
  def input_view(type, name), do: {:input, [data(:name, name), type: type], []}
  def field_view(name), do: {:span, [data(:name, name)], []}

  def form_input_view(label, type, name) do
    {:div, [],
     [
       label_view(label),
       input_view(type, name)
     ]}
  end

  # def pickup_view(scope, name) do
  #  {:div, [data("pickup", scope), data("pickup-name", name)],
  #   [
  #     {:p, [], [label_view(name)]},
  #     {:p, [],
  #      [
  #        {:span, [data("pickup-selection", "display")], []}
  #      ]},
  #     {:p, [],
  #      [
  #        {:input, [data("pickup-input"), type: "text"], []}
  #      ]},
  #     {:div, [],
  #      [
  #        {:template, [data(:each)],
  #         [
  #           {:p, [],
  #            [
  #              field_view(:display)
  #            ]}
  #         ]}
  #      ]}
  #   ]}
  # end

  def button_view(action, label \\ "Submit") do
    {:button, [data(:action, action)], [label]}
  end
end

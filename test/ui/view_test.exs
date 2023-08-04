defmodule Sleeky.UI.ViewTest do
  use ExUnit.Case

  describe "views" do
    test "have an internal definition" do
      assert {:nav, [], [{:a, [href: "/"], ["Home"]}]} == HeaderView.definition()

      assert {:section, [id: "main"],
              [
                {:p, [class: "title"], ["Hero title"]},
                {:label, [], ["Enter your username"]},
                {:input, [type: "text"], []},
                {:button, [], ["Submit"]}
              ]} == MainView.definition()

      assert {:html, [],
              [
                {:head, [],
                 [
                   {:meta, [charset: "utf-8"], []},
                   {:title, [], ["Some title"]},
                   {:link, [rel: "stylesheet", href: "/some.css"], []}
                 ]},
                {:body, [],
                 [
                   {:header, [], [{:slot, [], [:header]}]},
                   {:main, [], [{:slot, [], [:main]}]},
                   {:footer, [], [{:footer, [], ["This is the footer"]}]}
                 ]}
              ]} == LayoutView.definition()

      assert {:view, LayoutView, [header: {:view, HeaderView, []}, main: {:view, MainView, []}]} ==
               IndexView.definition()
    end
  end
end

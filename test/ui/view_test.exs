defmodule Sleeky.Ui.ViewTest do
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

    test "are resolved" do
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
                   {:header, [], [{:nav, [], [{:a, [href: "/"], ["Home"]}]}]},
                   {:main, [],
                    [
                      {:section, [id: "main"],
                       [
                         {:p, [class: "title"], ["Hero title"]},
                         {:label, [], ["Enter your username"]},
                         {:input, [type: "text"], []},
                         {:button, [], ["Submit"]}
                       ]}
                    ]},
                   {:footer, [], [{:footer, [], ["This is the footer"]}]}
                 ]}
              ]} == IndexView.resolve()
    end

    test "are converted to valid html" do
      assert {:ok, _document} = IndexView.to_html() |> Floki.parse_document()
    end
  end
end

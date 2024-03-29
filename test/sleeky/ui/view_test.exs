defmodule Sleeky.Ui.ViewTest do
  use ExUnit.Case

  describe "views" do
    test "have an internal definition" do
      assert {:render, [], [{:nav, [], [{:a, [href: "/"], ["Home"]}]}]} == HeaderView.definition()

      assert {:render, [],
              [
                {:section, [id: "main"],
                 [
                   {:p, [class: "title"], ["Hero title"]},
                   {:label, [], ["Enter your username"]},
                   {:input, [type: "text"], []},
                   {:button, [], ["Submit"]}
                 ]}
              ]} == MainView.definition()

      assert {:render, [],
              [
                {:html, [],
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
                      {:footer, [], ["This is the footer"]}
                    ]}
                 ]}
              ]} == LayoutView.definition()

      assert {:render, [],
              [
                {:view, [name: LayoutView],
                 [
                   {:slot, [name: :header], [{:view, [], [HeaderView]}]},
                   {:slot, [name: :main], [{:view, [], [MainView]}]}
                 ]}
              ]} ==
               IndexView.definition()
    end

    test "are compiled" do
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
                   {:footer, [], ["This is the footer"]}
                 ]}
              ]} == IndexView.compile()
    end

    test "support solid templating" do
      assert {:h1, [class: "title is-1"], ["Some title"]} ==
               SolidView.compile(style: "is-1")
    end

    test "raise an error when children slots don't have a value" do
      defmodule InvalidView do
        use Sleeky.Ui.View

        render do
          view LayoutView do
            slot :main do
              view MainView
            end
          end
        end
      end

      assert_raise RuntimeError,
                   ~r/No value for slot :header/,
                   &InvalidView.compile/0
    end

    test "raise an error when slots in attributes don't have a value" do
      assert_raise RuntimeError,
                   ~r/Error rendering template title {{ style }}/,
                   &SolidView.compile/0
    end

    test "are converted to valid html" do
      assert {:ok, _document} = IndexView.to_html() |> Floki.parse_document()
    end
  end
end

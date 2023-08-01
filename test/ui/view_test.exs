defmodule Sleeky.Ui.ViewTest do
  use ExUnit.Case

  describe "views" do
    defmodule SomeView do
      use Sleeky.UI.View

      render do
        html do
          head do
            meta charset: "utf-8"
            title "Some title"
            link rel: "stylesheet", href: "/some.css"
          end

          body do
            section class: "hero" do
              div class: "hero-body" do
                p class: "title" do
                  "Hero title"
                end

                p class: "subtitle" do
                  "Hero subtitle"
                end
              end
            end
          end
        end
      end
    end

    test "have an internal definition" do
      assert {:html, [],
              [
                {:head, [], head},
                {:body, [], body}
              ]} = SomeView.definition()

      assert [
               {:meta, [charset: "utf-8"], []},
               {:title, [], ["Some title"]},
               {:link, [rel: "stylesheet", href: "/some.css"], []}
             ] == head

      assert [
               {:section, [class: "hero"],
                [
                  {:div, [class: "hero-body"],
                   [
                     {:p, [class: "title"], ["Hero title"]},
                     {:p, [class: "subtitle"], ["Hero subtitle"]}
                   ]}
                ]}
             ] == body
    end
  end
end

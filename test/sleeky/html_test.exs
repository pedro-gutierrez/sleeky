defmodule Sleeky.HtmlTest do
  use ExUnit.Case

  alias TestHtml.{NamedItems, NamedMenu, Div, Items, Menu, Page}

  describe "html" do
    test "renders liquid variables" do
      params = %{"title" => "Foo", "myClass" => "bar"}

      assert "<div id=\"myDiv\" class=\"bar\">Foo</div>" = Div.render(params)
    end

    test "supports layouts and composition" do
      params = %{"title" => "Foo", "myClass" => "bar"}

      assert "<header><div id=\"myDiv\" class=\"bar\">Foo</div></header>" = Page.render(params)
    end

    test "generates liquid for loops" do
      params = %{"items" => ["one", "two", "three"]}

      assert "<ul><li>one</li><li>two</li><li>three</li></ul>" = Items.render(params)
    end

    test "supports compositions inside loops" do
      params = %{"items" => ["one", "two", "three"]}

      assert "<ul><li>one</li><li>two</li><li>three</li></ul>" = NamedItems.render(params)
    end

    test "expands data slots using inline html" do
      assert "<nav><a href=\"/one\">one</a><a href=\"/two\">two</a></nav>" = Menu.render()
    end

    test "expands data slots using named views" do
      assert "<nav><a href=\"/one\">one</a><a href=\"/two\">two</a></nav>" = NamedMenu.render()
    end
  end
end

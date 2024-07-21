defmodule Sleeky.ViewTest do
  use ExUnit.Case

  defmodule Div do
    use Sleeky.View

    view do
      div id: "myDiv", class: "{{ myClass }}" do
        "{{ title }}"
      end
    end
  end

  defmodule Layout do
    use Sleeky.View

    view do
      header do
        slot(:header)
      end
    end
  end

  defmodule Page do
    use Sleeky.View

    view do
      using Layout do
        slot :header do
          Div
        end
      end
    end
  end

  defmodule Items do
    use Sleeky.View

    view do
      ul do
        each :items, as: :item do
          li do
            "{{ item }}"
          end
        end
      end
    end
  end

  defmodule Item do
    use Sleeky.View

    view do
      li do
        "{{ item }}"
      end
    end
  end

  defmodule NamedItems do
    use Sleeky.View

    view do
      ul do
        each :items, as: :item do
          Item
        end
      end
    end
  end

  defmodule Link do
    use Sleeky.View

    view do
      a href: "{{ link.url }}" do
        "{{ link.title }}"
      end
    end
  end

  defmodule Nav do
    use Sleeky.View

    view do
      expand :links, as: :link do
        a href: "{{ link.url }}" do
          "{{ link.title }}"
        end
      end
    end
  end

  defmodule NamedNav do
    use Sleeky.View

    view do
      expand :links, as: :link do
        Link
      end
    end
  end

  defmodule Menu do
    use Sleeky.View

    view do
      nav do
        using Nav do
          slot :links do
            [url: "/one", title: "one"]
            [url: "/two", title: "two"]
          end
        end
      end
    end
  end

  defmodule NamedMenu do
    use Sleeky.View

    view do
      nav do
        using NamedNav do
          slot :links do
            [url: "/one", title: "one"]
            [url: "/two", title: "two"]
          end
        end
      end
    end
  end

  defmodule Html do
    use Sleeky.View

    view do
      html do
        head do
        end

        body do
        end
      end
    end
  end

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

    test "renders doctype for html pages" do
      assert "<!DOCTYPE html><html><head></head><body></body></html>" = Html.render()
    end
  end
end

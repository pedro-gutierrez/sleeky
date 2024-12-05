defmodule Sleeky.Ui.ViewTest do
  use ExUnit.Case

  defmodule Div do
    use Sleeky.Ui.View

    view do
      div id: "myDiv", class: "{{ myClass }}" do
        "{{ title }}"
      end
    end
  end

  defmodule Layout do
    use Sleeky.Ui.View

    view do
      header do
        slot(:header)
      end
    end
  end

  defmodule Page do
    use Sleeky.Ui.View

    view do
      component Layout do
        slot :header do
          Div
        end
      end
    end
  end

  defmodule Items do
    use Sleeky.Ui.View

    view do
      ul do
        each :item, in: :items do
          li do
            "{{ item }}"
          end
        end
      end
    end
  end

  defmodule Item do
    use Sleeky.Ui.View

    view do
      li do
        "{{ item }}"
      end
    end
  end

  defmodule NamedItems do
    use Sleeky.Ui.View

    view do
      ul do
        each :item, in: :items do
          Item
        end
      end
    end
  end

  defmodule Link do
    use Sleeky.Ui.View

    view do
      a href: "{{ link.url }}" do
        "{{ link.title }}"
      end
    end
  end

  defmodule Html do
    use Sleeky.Ui.View

    view do
      html do
        head do
        end

        body do
        end
      end
    end
  end

  defmodule VisibleView do
    use Sleeky.Ui.View

    view do
      p if: "{{ visible }}" do
        "Visible"
      end
    end
  end

  defmodule ChooseView do
    use Sleeky.Ui.View

    view do
      choose "{{ visible }}" do
        value "true" do
          p "Visible"
        end

        otherwise do
          p "Not visible"
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

    test "supports dot notation when interpolating values" do
      params = %{"link" => %{"url" => "https://example.com", "title" => "Example"}}

      assert "<a href=\"https://example.com\">Example</a>" == Link.render(params)
    end

    test "renders doctype for html pages" do
      assert "<!DOCTYPE html><html><head></head><body></body></html>" = Html.render()
    end

    test "supports if conditionals" do
      assert "<p>Visible</p>" == VisibleView.render(%{"visible" => true})
      assert "<div></div>" == VisibleView.render(%{"visible" => false})
    end

    test "supports switch case type of logic" do
      assert "<p>Visible</p>" == ChooseView.render(%{"visible" => true})
      assert "<p>Not visible</p>" == ChooseView.render(%{"visible" => false})
    end
  end
end

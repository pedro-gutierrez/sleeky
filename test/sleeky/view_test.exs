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
        slot :header
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

  defmodule Title do
    use Sleeky.Ui.View

    view do
      h1 do
        "{{ title }}"
      end
    end
  end

  defmodule ComponentView do
    use Sleeky.Ui.View

    view do
      component Title, using: "data"
    end
  end

  defmodule ComponentWithDotUsingView do
    use Sleeky.Ui.View

    view do
      component Title, using: "foo.bar"
    end
  end

  defmodule ComponentWithStaticParamView do
    use Sleeky.Ui.View

    view do
      component Title do
        slot :title do
          "Static Title"
        end
      end
    end
  end

  defmodule CompactParamsView do
    use Sleeky.Ui.View

    view do
      component Title, title: "{{ title }}"
    end
  end

  defmodule ComponentWithoutParamsView do
    use Sleeky.Ui.View

    view do
      component Title
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

  defmodule IfView do
    use Sleeky.Ui.View

    view do
      p if: "{{ visible }}" do
        "Visible"
      end
    end
  end

  defmodule UnlessView do
    use Sleeky.Ui.View

    view do
      p unless: "{{ hidden }}" do
        "Visible"
      end
    end
  end

  defmodule IfViewAsComponentView do
    use Sleeky.Ui.View

    view do
      component IfView
    end
  end

  describe "html" do
    test "renders liquid variables" do
      params = %{"title" => "Foo", "myClass" => "bar"}

      assert "<div id=\"myDiv\" class=\"bar\">Foo</div>" = Div.render(params)
    end

    test "supports components as layouts" do
      params = %{"title" => "Foo", "myClass" => "bar"}

      assert "<header><div id=\"myDiv\" class=\"bar\">Foo</div></header>" = Page.render(params)
    end

    test "supports components as functions" do
      params = %{"data" => %{"title" => "Foo"}}

      assert "<h1>Foo</h1>" = ComponentView.render(params)
    end

    test "dynamically resolves params passed to components" do
      params = %{"foo" => %{"bar" => %{"title" => "Foo"}}}

      assert "<h1>Foo</h1>" == ComponentWithDotUsingView.render(params)
    end

    test "supports components without params" do
      params = %{"title" => "Foo"}

      assert "<h1>Foo</h1>" = ComponentWithoutParamsView.render(params)
    end

    test "supports components with static params" do
      params = %{"title" => "Ignored"}

      assert "<h1>Static Title</h1>" == ComponentWithStaticParamView.render(params)
    end

    test "supports components with compact params" do
      params = %{"title" => "Hello"}

      assert "<h1>Hello</h1>" == CompactParamsView.render(params)
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
      assert "<p>Visible</p>" == IfView.render(%{"visible" => true})
      assert "<span></span>" == IfView.render(%{"visible" => false})
    end

    test "supports unless conditionals" do
      assert "<p>Visible</p>" == UnlessView.render(%{"hidden" => false})
      assert "<span></span>" == UnlessView.render(%{"hidden" => true})
    end

    test "supports if conditionals inside components" do
      assert "<p>Visible</p>" == IfViewAsComponentView.render(%{"visible" => true})
      assert "<span></span>" == IfViewAsComponentView.render(%{"visible" => false})
    end
  end
end

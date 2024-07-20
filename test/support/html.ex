defmodule TestHtml do
  defmodule Div do
    use Sleeky.Html

    html do
      div id: "myDiv", class: "{{ myClass }}" do
        "{{ title }}"
      end
    end
  end

  defmodule Layout do
    use Sleeky.Html

    html do
      header do
        slot(:header)
      end
    end
  end

  defmodule Page do
    use Sleeky.Html

    html do
      using Layout do
        slot :header do
          Div
        end
      end
    end
  end

  defmodule Items do
    use Sleeky.Html

    html do
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
    use Sleeky.Html

    html do
      li do
        "{{ item }}"
      end
    end
  end

  defmodule NamedItems do
    use Sleeky.Html

    html do
      ul do
        each :items, as: :item do
          Item
        end
      end
    end
  end

  defmodule Link do
    use Sleeky.Html

    html do
      a href: "{{ link.url }}" do
        "{{ link.title }}"
      end
    end
  end

  defmodule Nav do
    use Sleeky.Html

    html do
      expand :links, as: :link do
        a href: "{{ link.url }}" do
          "{{ link.title }}"
        end
      end
    end
  end

  defmodule NamedNav do
    use Sleeky.Html

    html do
      expand :links, as: :link do
        Link
      end
    end
  end

  defmodule Menu do
    use Sleeky.Html

    html do
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
    use Sleeky.Html

    html do
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
end

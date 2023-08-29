defmodule Sleeky.Ui.MarkdownTest do
  use ExUnit.Case

  defmodule SimpleMarkdownView do
    use Sleeky.Ui.View

    render do
      markdown class: "article" do
        """
        # Sleeky

        **Sleeky** is a new Elixir framework that allows you to write
        **batteries included**, lean web applications in a **fast** and **declarative** way.
        """
      end
    end
  end

  defmodule CompactMarkdownView do
    use Sleeky.Ui.View

    render do
      markdown("**Sleek** Elixir applications")
    end
  end

  defmodule TemplatedMarkdownView do
    use Sleeky.Ui.View

    render do
      markdown "{{ content.summary }}"
    end
  end

  describe "ui markdown directive" do
    test "resolves markdown into html" do
      assert {:div, [class: "article"],
              [
                {:h1, [], ["Sleeky"]},
                {:p, [],
                 [
                   {:strong, [], ["Sleeky"]},
                   " is a new Elixir framework that allows you to write\n",
                   {:strong, [], ["batteries included"]},
                   ", lean web applications in a ",
                   {:strong, [], ["fast"]},
                   " and ",
                   {:strong, [], ["declarative"]},
                   " way."
                 ]}
              ]} == SimpleMarkdownView.resolve()
    end

    test "supports compact notation" do
      assert {:div, [], [{:p, [], [{:strong, [], ["Sleek"]}, " Elixir applications"]}]} ==
               CompactMarkdownView.resolve()
    end

    test "supports templating" do
      assert {:div, [], [{:p, [], ["Some title"]}]} ==
               TemplatedMarkdownView.resolve(%{
                 content: %{summary: "Some title"}
               })
    end
  end
end

defmodule Sleeky.Ui.ImportTest do
  use ExUnit.Case

  alias Sleeky.Ui.Tools.Import

  describe "view_module/2" do
    test "returns a new Sleey view module" do
      html = "<div></div>"
      code = Import.view_module(html, MyApp.Ui.MyView)
      assert code =~ "defmodule MyApp.Ui.MyView do\n"
      assert code =~ "render do\n"
      assert code =~ "div do\n"
    end

    test "does not output parenthesis" do
      html = """
        <div class="article">
          <p class="title">
            Importing views
          </p>
          <p class="body">
            is very handy
          </p>
        </div>
      """

      code = Import.view_module(html, MyApp.Ui.MyView)

      assert code =~ "div class: \"article\" do\n"
      assert code =~ "p class: \"title\" do\n"
      assert code =~ "p class: \"body\" do\n"
    end

    test "returns code that compiles" do
      html = """
        <div class="buttons">
          <button class="button is-info">Info</button>
          <button class="button is-success">Success</button>
          <button class="button is-warning">Warning</button>
          <button class="button is-danger">Danger</button>
        </div>
      """

      code = Import.view_module(html, MyApp.Ui.MyView)

      assert {:ok, _} = Code.string_to_quoted(code)
    end
  end
end

defmodule Sleeky.Ui.EachTest do
  use ExUnit.Case

  describe "ui each directive" do
    test "renders a template view for a list of items" do
      assert {:ul, [], [{:li, [], ["Buy Food"]}, {:li, [], ["Write Elixir"]}]} ==
               TodosView.resolve()
    end
  end
end

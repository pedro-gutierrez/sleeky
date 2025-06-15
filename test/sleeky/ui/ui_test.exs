defmodule Sleeky.Ui.UiTest do
  use Sleeky.DataCase

  describe "ui" do
    test "uses default actions and views" do
      conn = :get |> new_conn("/") |> Blogs.Ui.call()

      assert conn.resp_body =~ "Blogs Index Page"
    end
  end
end

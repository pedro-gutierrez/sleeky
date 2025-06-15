defmodule Sleeky.Endpoint.UiTest do
  use Sleeky.DataCase

  describe "an endpoint" do
    test "routes requests to the ui" do
      resp =
        get("/")
        |> html_response!()

      assert resp =~ "DOCTYPE"
      assert resp =~ "Blogs Index Page"
      assert resp =~ "It works!"
    end
  end
end

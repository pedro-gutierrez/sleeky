defmodule Sleeky.ApiTest do
  use Sleeky.DataCase

  # describe "create api" do
  #  test "checks the request content type" do
  #    payload = %{
  #      "data" => %{
  #        "type" => "authors",
  #        "id" => uuid(),
  #        "attributes" => %{
  #          "name" => "john"
  #        }
  #      }
  #    }

  #    "/api/publishing/authors"
  #    |> post(payload, headers: %{"content-type" => "foo"})
  #    |> json_response!(400)
  #  end

  #  test "requires a client generated id" do
  #    payload = %{
  #      "data" => %{
  #        "type" => "authors",
  #        "attributes" => %{
  #          "name" => "john"
  #        }
  #      }
  #    }

  #    "/api/publishing/authors"
  #    |> post(payload)
  #    |> json_response!(400)
  #  end

  #  test "creates models" do
  #    payload = %{
  #      "data" => %{
  #        "type" => "authors",
  #        "id" => uuid(),
  #        "attributes" => %{
  #          "name" => "john"
  #        }
  #      }
  #    }

  #    "/api/publishing/authors"
  #    |> post(payload)
  #    |> json_response!(201)
  #  end
  # end
end

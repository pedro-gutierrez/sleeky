defmodule Sleeky.Endpoint.HealthTest do
  use Sleeky.DataCase

  describe "an endpoint" do
    test "has a health check" do
      "/healthz"
      |> get()
      |> ok!()
    end
  end
end

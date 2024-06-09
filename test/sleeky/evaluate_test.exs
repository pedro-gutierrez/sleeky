defmodule Sleeky.EvaluateTest do
  use Sleeky.DataCase

  alias Sleeky.Evaluate

  setup [:comments]

  describe "evaluate/2" do
    test "resolves parents lazily", context do
      author = Evaluate.evaluate(context.blog, {:path, [:**, :author]})

      assert author == context.author
    end
  end
end

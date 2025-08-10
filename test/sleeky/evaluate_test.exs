defmodule Sleeky.EvaluateTest do
  use Sleeky.DataCase

  alias Sleeky.Evaluate

  setup [:comments]

  describe "evaluate/2" do
    test "resolves parents lazily", context do
      author = Evaluate.evaluate(context.blog, {:path, [:**, :author]})

      assert author == context.author
    end

    test "supports string keys" do
      context = %{ "foo" => %{ "bar" => 1}}
      assert 1 == Evaluate.evaluate(context, {:path, [:foo, :bar]})
    end
  end
end

defmodule Sleeky.Ui.View.Dsl do
  @moduledoc false

  @doc false
  def locals_without_parens, do: [render: :*]

  defmacro render(do: child) do
    quote do
      def definition, do: unquote(child)
    end
  end
end

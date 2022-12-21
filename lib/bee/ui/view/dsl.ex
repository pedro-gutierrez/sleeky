defmodule Bee.UI.View.Dsl do
  @moduledoc false

  defmacro render(do: content) do
    view = __CALLER__.module
    Module.put_attribute(view, :content, content)
  end
end

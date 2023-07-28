defmodule Sleeki.UI.View.Dsl do
  @moduledoc false

  alias Sleeki.UI.View.Raw

  defmacro render(do: raw) do
    view = __CALLER__.module
    Module.put_attribute(view, :definition, Raw.parse(raw))
  end
end

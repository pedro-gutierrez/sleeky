defmodule Sleeky.Rest.Dsl do
  @moduledoc false

  defmacro schema({:__aliases__, _, mod}) do
    rest = __CALLER__.module
    schema = Module.concat(mod)
    Module.put_attribute(rest, :schema, schema)
  end
end

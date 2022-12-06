defmodule Bee.Schema.Dsl do
  defmacro context({:__aliases__, _, mod}) do
    schema = __CALLER__.module
    context = Module.concat(mod)
    Module.put_attribute(schema, :contexts, context)
  end
end

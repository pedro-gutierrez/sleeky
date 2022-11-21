defmodule Bee.Schema.Dsl do
  defmacro add({:__aliases__, _, mod}) do
    schema = __CALLER__.module
    entity = Module.concat(mod)
    Module.put_attribute(schema, :entities, entity)
  end
end

defmodule Sleeki.Schema.Dsl do
  defmacro entity({:__aliases__, _, mod}) do
    schema = __CALLER__.module
    entity = Module.concat(mod)
    Module.put_attribute(schema, :entities, entity)
  end

  defmacro enum({:__aliases__, _, mod}) do
    schema = __CALLER__.module
    enum = Module.concat(mod)
    Module.put_attribute(schema, :enums, enum)
  end
end

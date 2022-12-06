defmodule Bee.Context.Dsl do
  defmacro entity({:__aliases__, _, mod}) do
    context = __CALLER__.module
    entity = Module.concat(mod)
    Module.put_attribute(context, :entities, entity)
  end

  defmacro enum({:__aliases__, _, mod}) do
    context = __CALLER__.module
    enum = Module.concat(mod)
    Module.put_attribute(context, :enums, enum)
  end
end

defmodule Bee.Rest do
  defmacro __using__(_) do
    Module.register_attribute(__CALLER__.module, :schema, persist: true, accumulate: false)

    quote do
      import Bee.Rest, only: :macros
      @before_compile Bee.Rest
    end
  end

  defmacro schema({:__aliases__, _, mod}) do
    schema = Module.concat(mod)
    Module.put_attribute(__CALLER__.module, :schema, schema)
  end

  defmacro __before_compile__(_env) do
    schema = Module.get_attribute(__CALLER__.module, :schema)
    Code.ensure_compiled!(schema)

    # for e <- Bee.Schema.entities(schema) do
    #  IO.inspect(
    #    entity: e,
    #    attributes: Bee.Entity.attributes(e),
    #    parents: Bee.Entity.parents(e),
    #    children: Bee.Entity.children(e)
    #  )
    # end

    :ok
  end
end

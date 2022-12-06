defmodule Bee.Schema do
  defmacro __using__(_) do
    Module.register_attribute(__CALLER__.module, :entities, persist: true, accumulate: true)
    Module.register_attribute(__CALLER__.module, :enums, persist: true, accumulate: true)

    quote do
      import Bee.Schema.Dsl, only: :macros
      @before_compile unquote(Bee.Schema)
    end
  end

  defmacro __before_compile__(_env) do
    schema = __CALLER__.module
    entities = Module.get_attribute(schema, :entities)
    Module.delete_attribute(schema, :entities)
    enums = Module.get_attribute(schema, :enums)
    Module.delete_attribute(schema, :enums)

    quote do
      def entities, do: unquote(entities)
      def enums, do: unquote(enums)
    end
  end
end

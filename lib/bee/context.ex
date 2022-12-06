defmodule Bee.Context do
  defmacro __using__(_) do
    context = __CALLER__.module
    Module.register_attribute(context, :entities, persist: true, accumulate: true)
    Module.register_attribute(context, :enums, persist: true, accumulate: true)

    quote do
      import Bee.Context.Dsl, only: :macros
      @before_compile unquote(Bee.Context)
    end
  end

  defmacro __before_compile__(_env) do
    context = __CALLER__.module
    entities = Module.get_attribute(context, :entities)
    Module.delete_attribute(context, :entities)
    enums = Module.get_attribute(context, :enums)
    Module.delete_attribute(context, :enums)

    quote do
      def entities, do: unquote(entities)
      def enums, do: unquote(enums)
    end
  end
end

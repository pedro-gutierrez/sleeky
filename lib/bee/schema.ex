defmodule Bee.Schema do
  defmacro __using__(_) do
    Module.register_attribute(__CALLER__.module, :contexts, persist: true, accumulate: true)

    quote do
      import Bee.Schema.Dsl, only: :macros
      @before_compile unquote(Bee.Schema)
    end
  end

  defmacro __before_compile__(_env) do
    schema = __CALLER__.module
    contexts = Module.get_attribute(schema, :contexts)
    Module.delete_attribute(schema, :contexts)

    quote do
      def contexts, do: unquote(contexts)
    end
  end
end

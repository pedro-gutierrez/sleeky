defmodule Bee.Schema do
  defmacro __using__(_opts) do
    schema = __CALLER__.module
    Module.register_attribute(schema, :contexts, persist: false, accumulate: true)
    Module.register_attribute(schema, :repo, persist: false, accumulate: false)

    quote do
      import Bee.Schema.Dsl, only: :macros
      @before_compile unquote(Bee.Schema)
    end
  end

  defmacro __before_compile__(_env) do
    schema = __CALLER__.module
    contexts = Module.get_attribute(schema, :contexts)

    quote do
      def contexts, do: unquote(contexts)
    end
  end
end

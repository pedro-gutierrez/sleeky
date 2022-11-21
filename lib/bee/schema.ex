defmodule Bee.Schema do
  defmacro __using__(_) do
    Module.register_attribute(__CALLER__.module, :entities, persist: true, accumulate: true)

    quote do
      import Bee.Schema.Dsl, only: :macros
      @before_compile unquote(Bee.Schema)
    end
  end

  defmacro __before_compile__(_env) do
    _schema = __CALLER__.module
  end

  def entities(schema), do: Module.get_attribute(schema, :entities)
end

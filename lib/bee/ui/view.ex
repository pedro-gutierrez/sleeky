defmodule Bee.UI.View do
  @moduledoc false

  import Bee.Inspector

  defstruct [:route, :module, :render]

  def new(opts) do
    struct(__MODULE__, opts)
  end

  def named(name, parent) do
    parent |> context() |> module(name)
  end

  def ast(definition) do
    quote do
      @definition unquote(Macro.escape(definition))
      use Bee.UI.View.Resolve
    end
  end

  defmacro __using__(_opts) do
    quote do
      import Bee.UI.View.Dsl, only: :macros
      @before_compile Bee.UI.View
    end
  end

  defmacro __before_compile__(_env) do
    __CALLER__.module
    |> Module.get_attribute(:definition)
    |> ast()
  end
end

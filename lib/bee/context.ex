defmodule Bee.Context do
  @moduledoc false

  import Bee.Inspector

  @generators [
    Bee.Context.Info,
    Bee.Context.ListActions
  ]

  defmacro __using__(opts) do
    context = __CALLER__.module
    Module.register_attribute(context, :entities, persist: false, accumulate: true)
    Module.register_attribute(context, :enums, persist: false, accumulate: true)

    repo = opts |> Keyword.fetch!(:repo) |> module()
    Module.put_attribute(context, :repo, repo)

    quote do
      import Bee.Context.Dsl, only: :macros
      @before_compile unquote(Bee.Context)
    end
  end

  defmacro __before_compile__(_env) do
    context = __CALLER__.module
    repo = Module.get_attribute(context, :repo)
    entities = Module.get_attribute(context, :entities)
    enums = Module.get_attribute(context, :enums)
    opts = [repo: repo, context: context]

    Enum.flat_map(@generators, & &1.ast(entities, enums, opts))
  end
end

defmodule Bee.Context do
  @moduledoc false

  import Bee.Inspector

  @generators [
    Bee.Context.Preamble,
    Bee.Context.Helpers,
    Bee.Context.List
  ]

  defmacro __using__(opts) do
    context = __CALLER__.module
    Module.register_attribute(context, :entities, persist: false, accumulate: true)
    Module.register_attribute(context, :enums, persist: false, accumulate: true)

    repo = opts |> Keyword.fetch!(:repo) |> module()
    Module.put_attribute(context, :repo, repo)

    auth = opts |> Keyword.fetch!(:auth) |> module()
    Module.put_attribute(context, :auth, auth)

    quote do
      import Bee.Context.Dsl, only: :macros
      @before_compile unquote(Bee.Context)
    end
  end

  defmacro __before_compile__(_env) do
    context = __CALLER__.module
    repo = Module.get_attribute(context, :repo)
    auth = Module.get_attribute(context, :auth)
    entities = Module.get_attribute(context, :entities)
    enums = Module.get_attribute(context, :enums)
    opts = [repo: repo, auth: auth, context: context]

    Enum.flat_map(@generators, & &1.ast(entities, enums, opts))
    |> print()
  end
end

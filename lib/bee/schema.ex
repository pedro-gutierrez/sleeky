defmodule Bee.Schema do
  @moduledoc false

  @generators [
    Bee.Schema.Preamble,
    Bee.Schema.NearestPath,
    Bee.Schema.Evaluate
  ]

  import Bee.Inspector

  def entities!(schema) do
    ensure!(schema, :entities)
  end

  def enums!(schema) do
    Module.get_attribute(schema, :enums) || []
  end

  def repo!(schema) do
    ensure!(schema, :repo)
  end

  def auth!(schema) do
    ensure!(schema, :auth)
  end

  defp ensure!(schema, attr) do
    with nil <- Module.get_attribute(schema, attr) do
      raise "Attribute #{inspect(attr)} is missing in #{inspect(schema)}"
    end
  end

  defmacro __using__(_opts) do
    schema = __CALLER__.module

    Module.register_attribute(schema, :entities, persist: false, accumulate: true)
    Module.register_attribute(schema, :enums, persist: false, accumulate: true)

    repo = schema |> context() |> module(Repo)
    Module.put_attribute(schema, :repo, repo)

    auth = schema |> context() |> module(Auth)
    Module.put_attribute(schema, :auth, auth)

    quote do
      import Bee.Schema.Dsl, only: :macros
      @before_compile unquote(Bee.Schema)
    end
  end

  defmacro __before_compile__(_env) do
    schema = __CALLER__.module

    @generators
    |> Enum.map(& &1.ast(schema))
    |> flatten()
  end
end

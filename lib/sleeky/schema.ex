defmodule Sleeky.Schema do
  @moduledoc """
  A schema acts as a container for a set of entities.

  ```elixir
  defmodule MyApp.Schema do
    use Sleeky.Schema

    entity MyApp.Schema.Blog
    entity Myapp.Schema.Post
  end
  ```
  """

  @generators [
    Sleeky.Schema.Preamble,
    Sleeky.Schema.NearestPath,
    Sleeky.Schema.Evaluate,
    Sleeky.Schema.Filter,
    Sleeky.Schema.Compare
  ]

  import Sleeky.Inspector

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
      import Sleeky.Schema.Dsl, only: :macros
      @before_compile unquote(Sleeky.Schema)
    end
  end

  defmacro __before_compile__(_env) do
    schema = __CALLER__.module

    @generators
    |> Enum.map(& &1.ast(schema))
    |> flatten()
  end
end

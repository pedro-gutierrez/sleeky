defmodule Bee.Auth do
  @moduledoc false
  import Bee.Inspector

  defmacro __using__(opts) do
    auth = __CALLER__.module
    schema = opts |> Keyword.fetch!(:schema) |> module()
    Module.put_attribute(auth, :schema, schema)

    quote do
      @before_compile unquote(Bee.Auth)
    end
  end

  defmacro __before_compile__(_env) do
    _auth = __CALLER__.module

    quote do
      def scope_query(_, _, query, _), do: query
      def allowed?(_, _, context), do: true
    end
  end
end

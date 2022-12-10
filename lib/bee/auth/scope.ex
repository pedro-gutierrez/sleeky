defmodule Bee.Auth.Scope do
  @moduledoc false

  def ast(_auth, _schema) do
    quote do
      def scope_query(_entity, _action, query, _context) do
        query
      end
    end
  end
end

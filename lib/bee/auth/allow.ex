defmodule Bee.Auth.Allow do
  @moduledoc false

  def ast(_auth, _schema) do
    quote do
      def allow_action(_entity, _action, _context) do
        :ok
      end
    end
  end
end

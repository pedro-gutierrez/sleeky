defmodule Sleeki.Entity.Virtual do
  @moduledoc false

  def ast(_entity) do
    quote do
      def virtual?, do: true
    end
  end
end

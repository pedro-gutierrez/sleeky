defmodule Sleeky.Domain.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(domain, _) do
    quote do
      import Ecto.Query

      def name, do: unquote(domain.name)
      def models, do: unquote(domain.models)
      def repo, do: unquote(domain.repo)
    end
  end
end

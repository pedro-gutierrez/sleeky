defmodule Sleeky.Model.Generator.ListFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, _model) do
    quote do
      def list(opts \\ []) do
        query = Keyword.get(opts, :query, __MODULE__)
        preload = Keyword.get(opts, :preload, [])
        query = from(q in query, order_by: [asc: q.inserted_at], preload: ^preload)

        opts =
          opts
          |> Keyword.take([:before, :after, :limit])
          |> Keyword.merge(
            include_total_count: true,
            cursor_fields: [:inserted_at]
          )

        @repo.paginate(query, opts)
      end
    end
  end
end

defmodule Sleeky.Entity.Generator.ListFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, _) do
    quote do
      def list(opts \\ []) do
        query = Keyword.get(opts, :query, __MODULE__)
        preload = Keyword.get(opts, :preload, [])
        query = from(q in query, preload: ^preload)

        query =
          opts
          |> Keyword.get(:sort, inserted_at: :asc)
          |> Enum.reduce(query, fn
            {field, :asc}, q -> q |> order_by([q], asc: field(q, ^field))
            {field, :desc}, q -> q |> order_by([q], desc: field(q, ^field))
          end)

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

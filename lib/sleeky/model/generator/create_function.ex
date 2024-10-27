defmodule Sleeky.Model.Generator.CreateFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(model, _) do
    [
      with_map_args(model),
      with_keyword_args(model),
      batch_fun(model)
    ]
  end

  defp with_map_args(model) do
    quote do
      def create(attrs) when is_map(attrs) do
        %__MODULE__{}
        |> insert_changeset(attrs)
        |> unquote(model.context).repo().insert()
      end
    end
  end

  defp with_keyword_args(_model) do
    quote do
      def create(attrs) when is_list(attrs) do
        attrs
        |> Map.new()
        |> create()
      end
    end
  end

  defp batch_fun(model) do
    quote do
      def create_many(items, opts \\ []) when is_list(items) do
        now = DateTime.utc_now()

        items =
          for item <- items do
            item
            |> atom_keys()
            |> Map.put_new_lazy(:id, &Ecto.UUID.generate/0)
            |> Map.put_new(:inserted_at, now)
            |> Map.put_new(:updated_at, now)
          end

        unquote(model.context).repo().insert_all(__MODULE__, items, opts)

        :ok
      end
    end
  end
end

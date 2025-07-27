defmodule Sleeky.Model.Generator.CreateFunction do
  @moduledoc false
  @behaviour Diesel.Generator

  alias Sleeky.Model
  alias Sleeky.Model.OnConflict

  @impl true
  def generate(model, _) do
    [
      with_defaults(),
      with_map_args(model),
      with_keyword_args(model),
      batch_fun(model)
    ]
  end

  defp with_defaults() do
    quote do
      def create(attrs, opts \\ [])
    end
  end

  defp with_map_args(model) do
    conflict_opts = on_conflict_opts(model) || []

    quote do
      def create(attrs, opts) when is_map(attrs) do
        opts = Keyword.merge(unquote(conflict_opts), opts)

        %__MODULE__{}
        |> insert_changeset(attrs)
        |> unquote(model.domain).repo().insert(opts)
      end
    end
  end

  defp with_keyword_args(_model) do
    quote do
      def create(attrs, opts) when is_list(attrs) do
        attrs
        |> Map.new()
        |> create(opts)
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

        unquote(model.domain).repo().insert_all(__MODULE__, items, opts)

        :ok
      end
    end
  end

  defp on_conflict_opts(%OnConflict{strategy: :merge, fields: fields, except: except})
       when length(except) > 0 do
    fields = Enum.map(fields, & &1.name)

    [on_conflict: {:replace_all_except, except}, conflict_target: fields, returning: true]
  end

  defp on_conflict_opts(%Model{} = model) do
    model.keys
    |> Enum.filter(& &1.on_conflict)
    |> Enum.map(&on_conflict_opts(&1.on_conflict))
    |> List.first()
  end
end

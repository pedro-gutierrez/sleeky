defmodule Sleeky.Event.Generator.Serialize do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(event, _opts) do
    field_names = Enum.map(event.fields, & &1.name)
    required_fields = event.fields |> Enum.filter(& &1.required) |> Enum.map(& &1.name)

    quote do
      import Ecto.Changeset

      def new(params) when is_map(params) do
        changeset =
          %__MODULE__{}
          |> cast(params, unquote(field_names))
          |> validate_required(unquote(required_fields))

        if changeset.valid? do
          {:ok, apply_changes(changeset)}
        else
          {:error, changeset}
        end
      end

      def new(params), do: new(Map.new(params))

      def serialize(%__MODULE__{} = event) do
        event
        |> Map.from_struct()
        |> Jason.encode()
      end

      def serialize(event) when is_map(event) do
        event
        |> Map.take(unquote(field_names))
        |> Jason.encode()
      end

      def deserialize(json) when is_binary(json) do
        with {:ok, data} <- Jason.decode(json),
             {:ok, event} <- new(data) do
          {:ok, event}
        end
      end

      def deserialize(data) when is_map(data) do
        new(data)
      end
    end
  end
end

defmodule Bee.Entity.Ecto.Display do
  @moduledoc false
  alias Bee.Entity
  alias Bee.Entity.Attribute

  def module(entity) do
    Module.concat(entity.module, Display)
  end

  def ast(entity) do
    with %Attribute{plugin: {__MODULE__, fields}} <- Entity.field(:display, entity) do
      module = module(entity)

      quote do
        defmodule unquote(module) do
          @moduledoc false
          @fields unquote(fields)

          def execute(args, _context) do
            with {:ok, values} <- values(args),
                 display <- values |> Enum.reverse() |> Enum.join(" ") do
              {:ok, display}
            end
          end

          defp values(args) do
            Enum.reduce_while(@fields, {:ok, []}, fn field, {:ok, acc} ->
              case Map.get(args, field) do
                value when is_binary(value) -> {:cont, {:ok, [value | acc]}}
                nil -> {:halt, {:error, :invalid}}
              end
            end)
          end
        end
      end
    end
  end
end

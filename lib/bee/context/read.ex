defmodule Bee.Context.Read do
  @moduledoc false

  alias Bee.Entity
  import Bee.Inspector

  def ast(entities, _enums, opts) do
    repo = Keyword.fetch!(opts, :repo)
    auth = Keyword.fetch!(opts, :auth)

    entities
    |> Enum.reject(& &1.virtual?)
    |> Enum.filter(&Entity.action(:read, &1))
    |> Enum.map(fn entity ->
      [
        read_by_id_function(entity, repo, auth),
        read_by_id_bang_function(entity),
        read_by_unique_attribute_functions(entity),
        read_by_unique_key_functions(entity)
      ]
    end)
    |> flatten()
  end

  defp read_by_id_function(entity, repo, auth) do
    entity_name = entity.name()
    function_name = Entity.read_function(entity)

    quote do
      def unquote(function_name)(id, context \\ %{}) do
        preloads = []

        case unquote(entity) |> unquote(repo).get(id) |> unquote(repo).preload(preloads) do
          nil ->
            {:error, :not_found}

          item ->
            with true <- unquote(auth).allowed?(unquote(entity_name), :read, context) do
              {:ok, item}
            end
        end
      end
    end
  end

  defp read_by_id_bang_function(entity) do
    function_name = Entity.read_function(entity)
    bang_function_name = String.to_atom("#{function_name}!")

    quote do
      def unquote(bang_function_name)(id, context \\ %{}) do
        case unquote(function_name)(id, context) do
          {:ok, item} -> item
          {:error, :not_found} -> raise "No such item"
          other -> other
        end
      end
    end
  end

  defp read_by_unique_attribute_functions(_entity) do
    []
  end

  defp read_by_unique_key_functions(_entity) do
    []
  end
end

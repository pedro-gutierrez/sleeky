defmodule Bee.Context.Read do
  @moduledoc false

  alias Bee.Entity
  import Bee.Inspector

  def ast(entity, repo, _auth) do
    if Entity.action(:read, entity) do
      [
        read_by_id_function(entity, repo),
        read_by_id_bang_function(entity),
        read_by_unique_key_functions(entity, repo)
      ]
    else
      []
    end
  end

  defp read_by_id_function(entity, repo) do
    function_name = Entity.single_function_name(:read, entity)

    quote do
      def unquote(function_name)(id, context \\ %{}) do
        preloads = []

        unquote(entity)
        |> unquote(repo).get(id)
        |> unquote(repo).preload(preloads)
        |> check_allowed(unquote(entity), :read, context)
      end
    end
  end

  defp read_by_id_bang_function(entity) do
    function_name = Entity.single_function_name(:read, entity)
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

  defp read_by_unique_key_functions(entity, repo) do
    for key <- entity.keys() |> Enum.filter(& &1.unique) do
      function_name = key.read_function_name
      args = key.fields |> names() |> vars()

      filters = filters_for_key(entity, key)

      quote do
        def unquote(function_name)(unquote_splicing(args), context \\ %{}) do
          preloads = []

          unquote(entity)
          |> unquote(repo).get_by([unquote_splicing(filters)])
          |> unquote(repo).preload(preloads)
          |> check_allowed(unquote(entity), :read, context)
        end
      end
    end
  end

  defp filters_for_key(entity, key) do
    for field <- key.fields do
      {:ok, column} = entity.column_for(field.name)
      var = var(field.name)

      quote do
        {unquote(column), unquote(var)}
      end
    end
  end
end

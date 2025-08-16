defmodule Sleeky.Model.Generator.FetchFunction do
  @moduledoc false
  @behaviour Diesel.Generator
  import Sleeky.Naming

  @impl true
  def generate(model, _),
    do: [
      fetch_function(),
      fetch_bang_function(),
      fetch_by_unique_key_functions(model)
    ]

  defp fetch_function do
    quote do
      def fetch(id, opts \\ []) do
        preload = Keyword.get(opts, :preload, [])

        case __MODULE__ |> @repo.get(id) |> @repo.preload(preload) do
          nil -> {:error, :not_found}
          model -> {:ok, model}
        end
      end
    end
  end

  defp fetch_bang_function do
    quote do
      def fetch!(id, opts \\ []) do
        case fetch(id, opts) do
          {:error, :not_found} ->
            raise "record #{inspect(id)} of model #{inspect(__MODULE__)} not found"

          {:ok, model} ->
            model
        end
      end
    end
  end

  defp fetch_by_unique_key_functions(model) do
    for %{unique?: true} = key <- model.keys do
      fun_name = String.to_atom("fetch_by_#{key.name}")
      arg_names = Enum.map(key.fields, & &1.name)
      args = Enum.map(arg_names, &var(&1))

      clauses =
        for arg <- arg_names do
          quote do
            {unquote(arg), unquote(var(arg))}
          end
        end

      quote do
        def unquote(fun_name)(unquote_splicing(args), opts \\ []) do
          preload = Keyword.get(opts, :preload, [])
          clauses = unquote(clauses)

          case __MODULE__ |> @repo.get_by(clauses) |> @repo.preload(preload) do
            nil -> {:error, :not_found}
            model -> {:ok, model}
          end
        end
      end
    end
  end
end

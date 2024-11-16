defmodule Sleeky.Ui.Action.Generator.Render do
  @moduledoc false
  @behaviour Diesel.Generator

  alias Sleeky.Ui.Action.View
  alias Sleeky.Ui.Action.Redirect

  @impl true
  def generate(action, _opts) do
    [
      render_fun(action),
      results_funs(action),
      default_result_fun(action)
    ]
  end

  defp results_funs(action) do
    Enum.map(action.results, fn
      %View{name: name, module: view} ->
        quote do
          defp result({:ok, unquote(name), data}), do: unquote(view).render(data)
        end

      %Redirect{name: name, path: path} ->
        quote do
          defp result({:ok, unquote(name), _data}), do: "Redirecting to #{unquote(path)}"
        end
    end)
  end

  defp default_result_fun(_action) do
    quote do
      defp result(other), do: raise("Unknown result: #{inspect(other)}")
    end
  end

  defp render_fun(action) do
    quote do
      def render(params) do
        params
        |> unquote(action.module).execute()
        |> result()
      end
    end
  end
end

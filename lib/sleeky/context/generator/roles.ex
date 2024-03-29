defmodule Sleeky.Context.Generator.Roles do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(_, context), do: roles_fun(context.authorization, context)

  defp roles_fun(nil, _) do
    quote do
      def roles(_params), do: []
    end
  end

  defp roles_fun(auth, _) do
    roles_path = {:path, auth.roles()}

    quote do
      def roles(params) do
        Sleeky.Evaluate.evaluate(params, unquote(roles_path)) || []
      end
    end
  end
end

defmodule Sleeky.Feature.Generator.Commands do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _opts) do
    for command <- feature.commands do
      fun_name = command.fun_name()

      quote do
        def unquote(fun_name)(params), do: Sleeky.Feature.execute(unquote(command), params)

        def unquote(fun_name)(params, context),
          do: Sleeky.Feature.execute(unquote(command), params, context)
      end
    end
  end
end

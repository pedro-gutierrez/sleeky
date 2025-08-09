defmodule Sleeky.Feature.Generator.Commands do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _opts) do
    for command <- feature.commands do
      command_fun(command, feature)
    end
  end

  def command_fun(command, feature) do
    fun_name = Sleeky.Command.Helper.fun_name(command)
    params_module = command.params()

    command_invocation =
      if command.atomic?() do
        quote do
          with {:ok, :ok} <-
                 unquote(feature.repo).transaction(fn ->
                   with {:error, reason} <- unquote(command).execute(params, context) do
                     unquote(feature.repo).rollback(reason)
                   end
                 end),
               do: :ok
        end
      else
        quote do
          unquote(command).execute(params, context)
        end
      end

    quote do
      def unquote(fun_name)(params, context \\ {}) do
        with {:ok, params} <- unquote(params_module).validate(params),
             context <- Map.put(context, :params, params),
             :ok <- Sleeky.Feature.allow(unquote(command), context) do
          unquote(command_invocation)
        end
      end
    end
  end
end

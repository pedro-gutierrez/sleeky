defmodule Sleeky.Flow.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Flow
  alias Sleeky.Flow.Step

  import Sleeky.Naming

  def parse({:flow, attrs, children}, opts) do
    caller = Keyword.fetch!(opts, :caller_module)
    feature = feature_module(caller)
    model = Keyword.fetch!(attrs, :model)
    params = Keyword.get(attrs, :params, model)
    event = Keyword.fetch!(attrs, :publish)
    fun_name = module_fun_name(caller)
    create_model_fun_name = String.to_atom("create_#{module_fun_name(model)}")

    steps =
      for {:steps, _attrs, commands} <- children, command <- commands do
        name = step_name(command)

        %Step{name: name, command: command}
      end
      |> List.flatten()

    %Flow{
      feature: feature,
      fun_name: fun_name,
      create_model_fun_name: create_model_fun_name,
      model: model,
      params: params,
      event: event,
      steps: steps
    }
  end

  defp step_name(command), do: module_fun_name(command)
end

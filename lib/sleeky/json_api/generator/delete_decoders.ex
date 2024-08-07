defmodule Sleeky.JsonApi.Generator.DeleteDecoders do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts, model <- context.models(), %{name: :delete} <- model.actions() do
      module_name = Module.concat(model, JsonApiDeleteDecoder)

      rules = %{
        "id" => [required: true, type: :string, uuid: true]
      }

      quote do
        defmodule unquote(module_name) do
          use Sleeky.Decoder,
            rules: unquote(Macro.escape(rules)),
            mappings: unquote(%{id: ["id"]})
        end
      end
    end
  end
end

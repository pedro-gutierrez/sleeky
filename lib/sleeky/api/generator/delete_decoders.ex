defmodule Sleeky.Api.Generator.DeleteDecoders do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts,
        entity <- context.entities(),
        %{name: :delete} <- entity.actions() do
      module_name = Module.concat(entity, ApiDeleteDecoder)

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

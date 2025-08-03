defmodule Sleeky.Api.Generator.ReadDecoders do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts,
        entity <- context.entities(),
        %{name: :read} <- entity.actions() do
      module_name = Module.concat(entity, ApiReadDecoder)
      include_decoder = Module.concat(entity, ApiIncludeDecoder)

      rules = %{
        "id" => [required: true, type: :string, uuid: true],
        "include" => [
          nullable: true,
          required: false,
          type: :string,
          custom: &include_decoder.decode/1
        ]
      }

      quote do
        defmodule unquote(module_name) do
          use Sleeky.Decoder,
            rules: unquote(Macro.escape(rules)),
            mappings: unquote(%{id: ["id"], preload: ["include"]})
        end
      end
    end
  end
end

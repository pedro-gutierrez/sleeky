defmodule Sleeky.Api.Generator.RelationDecoders do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts, entity <- context.entities() do
      module_name = Module.concat(entity, ApiRelationDecoder)

      quote do
        defmodule unquote(module_name) do
          use Sleeky.Decoder.RelationDecoder, entity: unquote(entity)
        end
      end
    end
  end
end

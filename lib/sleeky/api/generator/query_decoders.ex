defmodule Sleeky.Api.Generator.QueryDecoders do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts, entity <- context.entities() do
      module_name = Module.concat(entity, ApiQueryDecoder)

      quote do
        defmodule unquote(module_name) do
          use Sleeky.Decoder.QueryDecoder,
            entity: unquote(entity)
        end
      end
    end
  end
end

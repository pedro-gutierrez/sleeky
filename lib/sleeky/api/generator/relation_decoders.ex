defmodule Sleeky.Api.Generator.RelationDecoders do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for domain <- api.domains, model <- domain.models() do
      module_name = Module.concat(model, ApiRelationDecoder)

      quote do
        defmodule unquote(module_name) do
          use Sleeky.Decoder.RelationDecoder, model: unquote(model)
        end
      end
    end
  end
end

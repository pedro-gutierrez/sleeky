defmodule Sleeky.JsonApi.Generator.QueryDecoders do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts, model <- context.models() do
      module_name = Module.concat(model, JsonApiQueryDecoder)

      quote do
        defmodule unquote(module_name) do
          use Sleeky.Decoder.QueryDecoder,
            model: unquote(model)
        end
      end
    end
  end
end

defmodule Sleeky.Api.Generator.CreateDecoders do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Decoder

  @impl true
  def generate(api, _) do
    for context <- api.contexts,
        entity <- context.entities(),
        %{name: :create} <- entity.actions() do
      module_name = Module.concat(entity, ApiCreateDecoder)

      rules = %{"id" => [required: true, type: :string, uuid: true]}

      rules =
        for attr when attr.name not in [:id] <- entity.attributes(), into: rules do
          {to_string(attr.name), [] |> maybe_required(attr) |> attribute_type(attr)}
        end

      rules =
        for rel <- entity.parents(), into: rules do
          decoder = Module.concat(rel.target.module, ApiRelationDecoder)

          {to_string(rel.name), [] |> maybe_required(rel) |> relation_type(decoder)}
        end

      mappings = default_mappings(entity)

      quote do
        defmodule unquote(module_name) do
          use Sleeky.Decoder,
            rules: unquote(Macro.escape(rules)),
            mappings: unquote(mappings)
        end
      end
    end
  end
end

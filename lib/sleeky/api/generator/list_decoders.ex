defmodule Sleeky.Api.Generator.ListDecoders do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for context <- api.contexts,
        entity <- context.entities(),
        %{name: :list} <- entity.actions() do
      module_name = Module.concat(entity, ApiListDecoder)
      include_decoder = Module.concat(entity, ApiIncludeDecoder)
      query_decoder = Module.concat(entity, ApiQueryDecoder)
      sort_decoder = Module.concat(entity, ApiSortDecoder)

      rules = %{
        "query" => [
          nullable: true,
          required: false,
          type: :string,
          custom: &query_decoder.decode/1
        ],
        "sort" => [
          nullable: true,
          required: false,
          type: :string,
          custom: &sort_decoder.decode/1
        ],
        "include" => [
          nullable: true,
          required: false,
          type: :string,
          custom: &include_decoder.decode/1
        ],
        "limit" => [
          nullable: true,
          required: false,
          type: :string,
          cast: :integer
        ],
        "before" => [
          nullable: true,
          required: false,
          type: :string
        ],
        "after" => [
          nullable: true,
          required: false,
          type: :string
        ]
      }

      mappings = %{
        query: ["query"],
        sort: ["sort"],
        preload: ["include"],
        limit: ["limit"],
        before: ["before"],
        after: ["after"]
      }

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

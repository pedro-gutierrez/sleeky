defmodule Sleeky.Api.Generator.ListByParentDecoders do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(api, _) do
    for domain <- api.domains,
        model <- domain.models(),
        %{name: :list} <- model.actions(),
        rel <- model.parents() do
      module_name = Macro.camelize("api_list_by_#{rel.name}_decoder")
      module_name = Module.concat(model, module_name)
      parent_decoder = Module.concat(rel.target.module, ApiRelationDecoder)
      include_decoder = Module.concat(model, ApiIncludeDecoder)
      query_decoder = Module.concat(model, ApiQueryDecoder)
      sort_decoder = Module.concat(model, ApiSortDecoder)

      rules = %{
        "id" => [
          required: true,
          type: :string,
          uuid: true,
          custom: &parent_decoder.decode/1
        ],
        "include" => [
          nullable: true,
          required: false,
          type: :string,
          custom: &include_decoder.decode/1
        ],
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
        rel.name => ["id"],
        preload: ["include"],
        query: ["query"],
        sort: ["sort"],
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

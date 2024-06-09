defmodule Sleeky.JsonApi.MutationValidator do
  @moduledoc false

  defmacro __using__(opts) do
    model = Keyword.fetch!(opts, :model)
    attributes = Keyword.fetch!(opts, :attributes)
    relationships = Keyword.fetch!(opts, :relationships)
    type = model.plural() |> to_string()

    fields = %{
      "attributes" => [required: true, type: :map, map: attributes],
      "id" => [required: true, type: :string, uuid: true],
      "type" => [required: true, type: :string, in: [type]]
    }

    fields =
      if Enum.empty?(relationships) do
        fields
      else
        Map.put(fields, "relationships", relationships)
      end

    rules = %{
      "data" => [
        required: true,
        type: :map,
        map: fields
      ]
    }

    quote do
      use Sleeky.Validator, rules: unquote(Macro.escape(rules))
    end
  end
end

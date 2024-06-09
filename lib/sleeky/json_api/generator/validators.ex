defmodule Sleeky.JsonApi.Generator.Validators do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(_caller, api) do
    for context <- api.contexts, model <- context.models() do
      validator_module(model)
    end
  end

  defp validator_module(model) do
    module_name = Module.concat(model, JsonApiValidator)
    rules = rules(model)

    data_var = var(:data)

    cast_id = quote do: [{:id, unquote(data_var)["id"]}]

    cast_attributes =
      for attr when attr.name not in [:id] <- model.attributes() do
        quote do
          {unquote(attr.name),
           get_in(unquote(data_var), ["attributes", unquote(to_string(attr.name))])}
        end
      end

    cast_relations =
      for rel <- model.parents() do
        quote do
          {unquote(rel.name),
           get_in(unquote(data_var), [
             "relationships",
             unquote(to_string(rel.name)),
             "data",
             "id"
           ])}
        end
      end

    quote do
      defmodule unquote(module_name) do
        @rules unquote(Macro.escape(rules))

        def validate(input) do
          case Validate.validate(input, @rules) do
            {:ok, %{"data" => unquote(data_var)}} ->
              {:ok, Map.new(unquote(cast_id ++ cast_attributes ++ cast_relations))}

            {:error, errors} ->
              {:error, Validate.Util.errors_to_map(errors)}
          end
        end

        import Validate.Validator

        def resolve(%{value: id}) do
          case Ecto.UUID.cast(id) do
            {:ok, id} ->
              case unquote(model).fetch(id) do
                {:ok, model} -> success(model)
                {:error, :not_found} -> error("was not found")
              end

            _ ->
              {:error, error("not a valid uuid")}
          end
        end
      end
    end
  end

  defp rules(model) do
    type = type(model)
    attributes = attributes(model)
    relationships = relationships(model)

    fields = %{
      "attributes" => [required: true, type: :map, map: attributes],
      "id" => [required: true, type: :string, uuid: true],
      "type" => [required: true, type: :string, in: [type]]
    }

    fields =
      if Enum.empty?(relationships) do
        fields
      else
        Map.put(fields, "relationships", required: true, type: :map, map: relationships)
      end

    %{
      "data" => [
        required: true,
        type: :map,
        map: fields
      ]
    }
  end

  defp attributes(model) do
    for attr when attr.name not in [:id] <- model.attributes(), into: %{} do
      {to_string(attr.name), attr |> attribute_type() |> required(attr)}
    end
  end

  defp relationships(model) do
    for rel <- model.parents(), into: %{} do
      {to_string(rel.name), rel |> relation_type() |> required(rel)}
    end
  end

  defp required(opts, attr), do: Keyword.put(opts, :required, attr.required?)

  defp attribute_type(%{kind: :timestamp}),
    do: [
      type: :string,
      cast: {:datetime, "{ISO:Extended}"}
    ]

  defp attribute_type(attr), do: [type: attr.kind]

  defp relation_type(rel) do
    type = type(rel.target.module)
    relation_validator_module = Module.concat(rel.target.module, JsonApiValidator)

    [
      type: :map,
      map: %{
        "data" => [
          type: :map,
          required: true,
          map: %{
            "type" => [type: :string, required: true, in: [type]],
            "id" => [
              required: true,
              type: :string,
              custom: &relation_validator_module.resolve/1
            ]
          }
        ]
      }
    ]
  end

  defp type(module), do: module.plural() |> to_string()
end

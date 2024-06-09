defmodule Sleeky.Decoder do
  @moduledoc """
  A generic json api decoder based on Validate
  """

  import Sleeky.Naming

  defmacro __using__(opts) do
    rules = Keyword.fetch!(opts, :rules)
    mappings = Keyword.fetch!(opts, :mappings)

    data_var = var(:data)

    mappings =
      for {field, path} <- mappings do
        quote do
          {unquote(field), get_in(unquote(data_var), unquote(path))}
        end
      end

    quote do
      @rules unquote(rules)

      def decode(input) do
        case Validate.validate(input, @rules) do
          {:ok, unquote(data_var)} ->
            {:ok,
             unquote(mappings)
             |> remove_nils()
             |> Map.new()}

          {:error, errors} ->
            {:error, Validate.Util.errors_to_map(errors)}
        end
      end

      defp remove_nils(tuples), do: Enum.reject(tuples, fn {_, value} -> is_nil(value) end)
    end
  end

  def default_mappings(model) do
    mappings = %{id: ["id"]}

    mappings =
      for attr when attr.name not in [:id] <- model.attributes(), into: mappings do
        {attr.name, [to_string(attr.name)]}
      end

    for rel <- model.parents(), into: mappings do
      {rel.name, [to_string(rel.name), "id"]}
    end
  end

  def required(opts, attr), do: Keyword.merge(opts, required: attr.required?)
  def optional(opts), do: Keyword.merge(opts, required: false, nullable: true)

  def attribute_type(opts, %{kind: :timestamp}) do
    Keyword.merge(opts, type: :string, cast: {:datetime, "{ISO:Extended}"})
  end

  def attribute_type(opts, attr), do: Keyword.merge(opts, type: attr.kind)

  def relation_type(opts, decoder) do
    Keyword.merge(opts,
      type: :map,
      map: %{
        "id" => [
          required: true,
          type: :string,
          custom: &decoder.decode/1
        ]
      }
    )
  end
end

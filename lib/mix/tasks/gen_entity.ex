defmodule Mix.Tasks.Sleeky.Gen.Entity do
  @shortdoc "Creates a new Sleeky entity"

  @moduledoc """
  Creates a new Sleeky entity.

  Usage:

      mix sleeky.gen.entity --name Post
                            --description "A post entity"
                            --attributes title:string,public:boolean
                            --relations belongs_to:user
                            --actions read:admin

  A new Sleeky entity module will be generated and will be added to your schema.
  """
  use Mix.Task

  import Mix.Generator

  @switches [
    description: :string,
    name: :string,
    attributes: :string,
    relations: :string,
    actions: :string
  ]

  @impl true
  def run(argv) do
    {opts, _argv} = OptionParser.parse!(argv, strict: @switches)
    app = Mix.Project.config() |> Keyword.fetch!(:app)

    description = description!(opts)
    schema = schema!(app)
    name = entity_name!(opts)
    attributes = attributes!(opts)
    relations = relations!(opts)
    actions = actions(opts)
    mod = entity_module(schema, name)
    path = filename(mod)

    generate(mod, schema, description, attributes, relations, actions, path)
  end

  defp generate(mod, schema, description, attributes, relations, actions, filename) do
    assigns = [
      description: description,
      mod: mod,
      attributes: attributes,
      relations: relations,
      actions: actions
    ]

    exists? = File.exists?(filename)

    created = create_file(filename, entity_template(assigns))

    if !exists? && created, do: add_to_schema(mod, schema)
  end

  defp add_to_schema(mod, schema) do
    mod = mod |> Module.split() |> Enum.map(&String.to_atom/1)

    schema_file = filename(schema)

    {:defmodule, loc,
     [
       aliases,
       [
         do: {:__block__, [], body}
       ]
     ]} = schema_file |> File.read!() |> Code.string_to_quoted!()

    extra_ast = {:entity, [line: 1000], [{:__aliases__, [line: 1000], mod}]}

    code =
      {:defmodule, loc,
       [
         aliases,
         [
           do: {:__block__, [], body ++ [extra_ast]}
         ]
       ]}

    code = code |> Macro.to_string() |> Code.format_string!()
    File.write!(schema_file, code)

    Mix.shell().info(
      "Your schema #{inspect(schema)} has been updated.\nDon't forget to generate your migrations!"
    )
  end

  defp description!(opts), do: Keyword.fetch!(opts, :description)

  defp schema!(app) do
    app_module = app |> to_string() |> Macro.camelize()
    Module.concat([app_module, "Schema"])
  end

  defp entity_name!(opts) do
    opts
    |> Keyword.fetch!(:name)
    |> Macro.camelize()
  end

  defp attributes!(opts) do
    opts
    |> Keyword.fetch!(:attributes)
    |> String.split(",")
    |> Enum.map(&attribute/1)
  end

  defp attribute(attr) do
    case String.split(attr, ":") do
      [name, kind] ->
        kind = String.to_atom(kind)
        %{name: name, kind: kind}

      _ ->
        Mix.raise("Invalid attribute format: #{attr}")
    end
  end

  defp relations!(opts) do
    opts
    |> Keyword.fetch!(:relations)
    |> String.split(",")
    |> Enum.map(&relation/1)
  end

  defp relation(rel) do
    case String.split(rel, ":") do
      [kind, target] ->
        kind = String.to_atom(kind)
        target = String.to_atom(target)
        %{kind: kind, target: target}

      _ ->
        Mix.raise("Invalid relation format: #{rel}")
    end
  end

  defp actions(opts) do
    opts
    |> Keyword.fetch!(:actions)
    |> String.split(",")
    |> Enum.map(&action/1)
  end

  defp action(action) do
    case String.split(action, ":") do
      [name, role] ->
        name = String.to_atom(name)
        role = String.to_atom(role)
        %{name: name, role: role}

      _ ->
        Mix.raise("Invalid action format: #{action}")
    end
  end

  defp entity_module(schema, name), do: Module.concat([schema, name])

  defp filename(mod) do
    Path.join(["lib", Macro.underscore(mod) <> ".ex"])
  end

  embed_template(:entity, """
  defmodule <%= @mod %> do
    @moduledoc \"\"\"
    <%= @description %>
    \"\"\"
    use Sleeky.Entity
    <%= for attr <- @attributes do %>
    attribute :<%= attr.name %>, :<%= attr.kind %><% end %>
    <%= for rel <- @relations do %>
    <%= rel.kind %> :<%= rel.target %><% end %>
    <%= for action <- @actions do %>
    action :<%= action.name %> do
      allow :<%= action.role %>
    end<% end %>
  end
  """)
end

defmodule Sleeky.Model do
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Model.Dsl,
    parsers: [
      Sleeky.Model.Parser
    ],
    generators: [
      Sleeky.Model.Generator.Metadata,
      Sleeky.Model.Generator.EctoSchema,
      Sleeky.Model.Generator.FieldNames,
      Sleeky.Model.Generator.Changesets,
      Sleeky.Model.Generator.CreateFunction,
      Sleeky.Model.Generator.FetchFunction,
      Sleeky.Model.Generator.EditFunction,
      Sleeky.Model.Generator.DeleteFunction,
      Sleeky.Model.Generator.ListFunction,
      Sleeky.Model.Generator.Query
    ]

  defstruct [
    :module,
    :context,
    :repo,
    :name,
    :plural,
    :primary_key,
    :table_name,
    virtual?: false,
    attributes: [],
    relations: [],
    keys: [],
    actions: []
  ]

  defmodule Key do
    @moduledoc false

    defstruct [
      :fields,
      :model,
      :name,
      unique?: false
    ]
  end

  defmodule Attribute do
    @moduledoc false

    defstruct [
      :name,
      :kind,
      :storage,
      :default,
      :enum,
      :column_name,
      required?: true,
      primary_key?: false,
      virtual?: false,
      computed?: false,
      mutable?: true,
      timestamp?: false,
      in: [],
      aliases: []
    ]
  end

  defmodule Relation do
    @moduledoc false

    defstruct [
      :name,
      :model,
      :kind,
      :target,
      :table_name,
      :column_name,
      :foreign_key_name,
      :storage,
      :inverse,
      :default,
      required?: true,
      virtual?: false,
      computed?: false,
      mutable?: true,
      aliases: []
    ]
  end

  defmodule Action do
    @moduledoc false

    defstruct [
      :name,
      :kind,
      policies: %{},
      tasks: []
    ]
  end

  defmodule Policy do
    @moduledoc false

    defstruct [
      :role,
      :scope,
      :policy
    ]
  end
end

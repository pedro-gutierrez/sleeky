defmodule Sleeky.Model do
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Model.Dsl,
    parsers: [
      Sleeky.Model.Parser
    ],
    generators: [
      Sleeky.Model.Generator.Metadata,
      Sleeky.Model.Generator.Cast,
      Sleeky.Model.Generator.EctoSchema,
      Sleeky.Model.Generator.Helpers,
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
    :domain,
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
      on_conflict: nil,
      unique?: false
    ]
  end

  defmodule Attribute do
    @moduledoc false

    defstruct [
      :name,
      :kind,
      :ecto_type,
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

  defmodule OnConflict do
    @moduledoc false

    defstruct [
      :fields,
      :strategy,
      :except
    ]
  end

  defmodule Task do
    @moduledoc false

    defstruct [
      :module,
      :if
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

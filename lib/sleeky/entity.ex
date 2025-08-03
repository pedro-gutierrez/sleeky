defmodule Sleeky.Entity do
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Entity.Dsl,
    parsers: [
      Sleeky.Entity.Parser
    ],
    generators: [
      Sleeky.Entity.Generator.Metadata,
      Sleeky.Entity.Generator.Cast,
      Sleeky.Entity.Generator.EctoSchema,
      Sleeky.Entity.Generator.Helpers,
      Sleeky.Entity.Generator.FieldNames,
      Sleeky.Entity.Generator.Changesets,
      Sleeky.Entity.Generator.CreateFunction,
      Sleeky.Entity.Generator.FetchFunction,
      Sleeky.Entity.Generator.EditFunction,
      Sleeky.Entity.Generator.DeleteFunction,
      Sleeky.Entity.Generator.ListFunction,
      Sleeky.Entity.Generator.Query
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
      :entity,
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
      :entity,
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

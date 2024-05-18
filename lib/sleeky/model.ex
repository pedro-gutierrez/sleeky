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
      Sleeky.Model.Generator.FieldSpec,
      Sleeky.Model.Generator.FieldNames,
      Sleeky.Model.Generator.Changesets,
      Sleeky.Model.Generator.Actions,
      Sleeky.Model.Generator.Query
    ]

  defstruct [
    :module,
    :context,
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
      :column_name,
      :storage,
      :inverse,
      required?: true,
      virtual?: false,
      aliases: []
    ]
  end

  defmodule Action do
    @moduledoc false

    defstruct [
      :name,
      :kind,
      policies: %{}
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

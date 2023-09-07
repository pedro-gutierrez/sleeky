defmodule Sleeky.Model do
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Model.Dsl,
    parsers: [
      Sleeky.Model.Parser
    ],
    generators: [
      Sleeky.Model.Generator.Metadata
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
    keys: []
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
    defstruct [
      :name,
      :kind,
      :storage,
      :default,
      :enum,
      :column_name,
      required?: true,
      primary_key?: false
    ]
  end

  defmodule Relation do
    defstruct [
      :name,
      :model,
      :kind,
      :target,
      :column_name,
      :storage,
      :inverse,
      required?: true
    ]
  end
end

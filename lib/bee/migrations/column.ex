defmodule Bee.Migrations.Column do
  @moduledoc false

  defstruct [
    :name,
    :kind,
    null: false
  ]
end

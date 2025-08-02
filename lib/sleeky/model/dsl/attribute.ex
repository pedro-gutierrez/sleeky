defmodule Sleeky.Model.Dsl.Attribute do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :atom, required: true

    attribute :kind,
      kind: :atom,
      in: [:integer, :float, :decimal, :string, :boolean, :datetime, :date, :text, :id],
      required: true

    attribute :required, kind: :boolean, required: false, default: true
    attribute :default, kind: :any, required: false
    attribute :in, kind: :list, required: false, default: []
  end
end

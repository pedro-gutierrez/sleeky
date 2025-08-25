defmodule Sleeky.Event.Dsl.Field do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :name, kind: :atom, required: true

    attribute :type,
      kind: :atom,
      in: [
        :integer,
        :float,
        :decimal,
        :string,
        :boolean,
        :datetime,
        :date,
        :text,
        :id
      ],
      required: true

    attribute :required, kind: :boolean, required: false, default: true
    attribute :default, kind: :any, required: false
    attribute :in, kind: :list, required: false, default: []
    attribute :many, kind: :boolean, required: false, default: false
  end
end

defmodule Sleeky.App.Dsl.App do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :roles, kind: :string, required: true
    child :repos, min: 0, max: 1
    child :endpoints, min: 0, max: 1
    child :features, min: 1, max: 1
  end
end

defmodule Sleeky.Ui.Route.Dsl.Route do
  @moduledoc false
  use Diesel.Tag

  tag do
    attribute :method, kind: :string, default: "get", in: ["get", "post", "put", "delete"]
    attribute :name, kind: :string
    attribute :action, kind: :module, required: false
    child :view, min: 0
  end
end

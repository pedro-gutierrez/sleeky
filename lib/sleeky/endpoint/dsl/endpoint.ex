defmodule Sleeky.Endpoint.Dsl.Endpoint do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :mount, min: 1
  end
end

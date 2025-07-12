defmodule Sleeky.App.Dsl.App do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :repos, min: 0, max: 1
    child :endpoints, min: 0, max: 1
    child :domains, min: 1, max: 1
  end
end

defmodule Sleeky.Context.Dsl.Context do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :model, min: 1
    child :authorization, min: 0
  end
end

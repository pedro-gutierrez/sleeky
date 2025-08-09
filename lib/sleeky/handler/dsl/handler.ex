defmodule Sleeky.Handler.Dsl.Handler do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :emits, min: 0
  end
end

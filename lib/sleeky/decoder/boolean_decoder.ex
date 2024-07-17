defmodule Sleeky.Decoder.BooleanDecoder do
  @moduledoc false

  import Validate.Validator

  def decode(%{value: value}) when value in [nil, "", 0, "false", false], do: success(false)
  def decode(%{value: _}), do: success(true)
end

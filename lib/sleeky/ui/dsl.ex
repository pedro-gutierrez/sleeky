defmodule Sleeky.Ui.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: :ui,
    tags: [:view, :bindings]
end

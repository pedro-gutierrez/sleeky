defmodule Sleeky.Ui.Namespace.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Ui.Namespace.Dsl.Namespace,
    tags: [
      Sleeky.Ui.Namespace.Dsl.Routes
    ]
end

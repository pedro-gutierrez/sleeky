defmodule Sleeky.Ui.Namespace do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Ui.Namespace.Dsl,
    generators: [
      Sleeky.Ui.Namespace.Generator.Router,
      Sleeky.Ui.Namespace.Generator.Metadata
    ]

  defstruct [:path, :routes]
end

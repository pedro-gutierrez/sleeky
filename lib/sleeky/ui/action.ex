defmodule Sleeky.Ui.Action do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Ui.Action.Dsl,
    generators: [
      Sleeky.Ui.Action.Generator.Render
    ]

  defstruct [:module, results: []]

  defmodule View do
    @moduledoc false
    defstruct [:name, :module]
  end

  defmodule Redirect do
    @moduledoc false
    defstruct [:name, :path]
  end
end

defmodule Sleeky.Ui do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Ui.Dsl,
    generators: [
      Sleeky.Ui.Generator.Router
    ]

  defstruct [:pages]

  defmodule Page do
    @moduledoc false
    defstruct [:method, :path, :module, :runtime]
  end
end

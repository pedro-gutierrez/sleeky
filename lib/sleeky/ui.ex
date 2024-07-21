defmodule Sleeky.Ui do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    generators: [
      Sleeky.Ui.Generator.Router
    ]

  defstruct [:pages]

  defmodule Page do
    @moduledoc false
    defstruct [:path, :module]
  end
end

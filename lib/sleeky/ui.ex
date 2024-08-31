defmodule Sleeky.Ui do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    generators: [
      Sleeky.Ui.Generator.Router,
      Sleeky.Ui.Generator.NewViews
    ]

  defstruct [:pages, :contexts]

  defmodule Page do
    @moduledoc false
    defstruct [:path, :module]
  end
end

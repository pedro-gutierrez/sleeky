defmodule Sleeky.Ui.View.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: :render,
    packages: [
      Sleeky.Ui.View.Dsl.Html,
      Sleeky.Ui.View.Dsl.Composition,
      Sleeky.Ui.View.Dsl.Markdown
    ]
end

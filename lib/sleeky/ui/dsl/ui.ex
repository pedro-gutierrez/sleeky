defmodule Sleeky.Ui.Dsl.Ui do
  @moduledoc false
  use Diesel.Tag

  tag do
    child :namespaces, min: 1
  end
end

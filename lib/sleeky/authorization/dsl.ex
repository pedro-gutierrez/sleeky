defmodule Sleeky.Authorization.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Authorization.Dsl.Authorization,
    tags: [
      Sleeky.Authorization.Dsl.Equal,
      Sleeky.Authorization.Dsl.Roles,
      Sleeky.Authorization.Dsl.Scope
    ]
end

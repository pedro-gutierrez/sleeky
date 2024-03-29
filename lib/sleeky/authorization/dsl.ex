defmodule Sleeky.Authorization.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Authorization.Dsl.Authorization,
    tags: [
      Sleeky.Authorization.Dsl.Eq,
      Sleeky.Authorization.Dsl.Path,
      Sleeky.Authorization.Dsl.Roles,
      Sleeky.Authorization.Dsl.Scope,
      Sleeky.Authorization.Dsl.One,
      Sleeky.Authorization.Dsl.All,
      Sleeky.Authorization.Dsl.NotNil
    ]
end

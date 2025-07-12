defmodule Sleeky.Scopes.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Scopes.Dsl.Scopes,
    tags: [
      Sleeky.Scopes.Dsl.Eq,
      Sleeky.Scopes.Dsl.Same,
      Sleeky.Scopes.Dsl.Member,
      Sleeky.Scopes.Dsl.Path,
      Sleeky.Scopes.Dsl.Roles,
      Sleeky.Scopes.Dsl.Scope,
      Sleeky.Scopes.Dsl.One,
      Sleeky.Scopes.Dsl.All,
      Sleeky.Scopes.Dsl.NotNil,
      Sleeky.Scopes.Dsl.IsTrue,
      Sleeky.Scopes.Dsl.IsFalse
    ]
end

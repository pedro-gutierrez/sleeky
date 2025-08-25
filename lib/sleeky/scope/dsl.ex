defmodule Sleeky.Scope.Dsl do
  @moduledoc false
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Scope.Dsl.Scope,
    tags: [
      Sleeky.Scope.Dsl.Eq,
      Sleeky.Scope.Dsl.Same,
      Sleeky.Scope.Dsl.Member,
      Sleeky.Scope.Dsl.Path,
      Sleeky.Scope.Dsl.One,
      Sleeky.Scope.Dsl.All,
      Sleeky.Scope.Dsl.NotNil,
      Sleeky.Scope.Dsl.IsTrue,
      Sleeky.Scope.Dsl.IsFalse
    ]
end

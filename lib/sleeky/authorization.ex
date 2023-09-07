defmodule Sleeky.Authorization do
  @moduledoc """
  Sleeky's authorization framework

  Usage:

  ```elixir
  defmodule MyApp.Blogs.Authorization do
    use Sleeky.Authorization

    authorization do
      roles path: "current_user.roles"

      scope :owner do
        equal do
          "**.user"
          "current_user"
        end
      end
    end
  end
  ```
  """
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Authorization.Dsl,
    generators: [
      Sleeky.Authorization.Generator.Authorize
    ]

  defstruct [:roles_path, :scopes]
end

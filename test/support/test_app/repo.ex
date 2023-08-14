defmodule TestApp.Repo do
  use Ecto.Repo,
    otp_app: :sleeky,
    adapter: Ecto.Adapters.Postgres
end

defmodule Blogs.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :sleeky,
    adapter: Ecto.Adapters.Postgres
end

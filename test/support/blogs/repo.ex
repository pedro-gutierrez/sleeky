defmodule Blogs.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :blogs,
    adapter: Ecto.Adapters.Postgres
end

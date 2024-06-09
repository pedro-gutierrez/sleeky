defmodule Blogs.Endpoint do
  @moduledoc false
  use Sleeky.Endpoint, otp_app: :sleeky, router: Blogs.Router
end

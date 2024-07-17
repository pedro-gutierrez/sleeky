defmodule Blogs.Endpoint do
  @moduledoc false
  use Sleeky.Endpoint, otp_app: :sleeky

  endpoint do
    mount Blogs.JsonApi, at: "/api"
  end
end

defmodule Blogs.Endpoint do
  @moduledoc false
  use Sleeky.Endpoint, otp_app: :sleeky

  endpoint do
    mount Blogs.Api, at: "/api"
    mount Blogs.Ui, at: "/"
  end
end

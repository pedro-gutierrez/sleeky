defmodule Blogs.Endpoint do
  @moduledoc false
  use Sleeky.Endpoint, otp_app: :sleeky

  endpoint do
    mount Blogs.JsonApi, at: "/api"
    mount Blogs.Ui, at: "/"
  end
end

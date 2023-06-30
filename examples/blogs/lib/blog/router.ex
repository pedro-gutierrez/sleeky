defmodule Blog.Router do
  use Bee.Router,
    otp_app: :blog,
    plugs: [Blog.PutUser]
end

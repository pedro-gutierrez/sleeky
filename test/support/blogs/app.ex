defmodule Blogs.App do
  @moduledoc false
  use Sleeky.App, otp_app: :sleeky

  app do
    domains do
      Blogs.Accounts
      Blogs.Notifications
      Blogs.Publishing
    end
  end
end

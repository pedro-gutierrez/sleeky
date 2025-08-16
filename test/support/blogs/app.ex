defmodule Blogs.App do
  @moduledoc false
  use Sleeky.App, otp_app: :sleeky

  app roles: "current_user.roles" do
    features do
      Blogs.Accounts
      Blogs.Notifications
      Blogs.Publishing
    end
  end
end

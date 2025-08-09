defmodule Blogs.Accounts.Handlers.RegisterUser do
  @moduledoc false

  def execute(user, context) do
    {:ok, user} = Blogs.Accounts.create_user(user, context)

    if user.email == "foo@bar.com" do
      {:error, :invalid_email}
    else
      {:ok, user}
    end
  end
end

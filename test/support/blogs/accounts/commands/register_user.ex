defmodule Blogs.Accounts.Commands.RegisterUser do
  @moduledoc false

  use Sleeky.Command

  alias Blogs.Accounts.User

  command params: User, atomic: true do
    policy role: :guest
  end

  def execute(user, context) do
    {:ok, user} = Blogs.Accounts.create_user(user, context)

    if user.email == "foo@bar.com" do
      {:error, :invalid_email}
    else
      {:ok, user}
    end
  end
end

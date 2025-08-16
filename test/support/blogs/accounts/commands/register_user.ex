defmodule Blogs.Accounts.Commands.RegisterUser do
  @moduledoc false

  use Sleeky.Command

  alias Blogs.Accounts.User
  alias Blogs.Accounts.Events.UserRegistered

  command params: User, atomic: true do
    policy role: :guest

    publish(event: UserRegistered)
  end

  def handle(%{email: "foo@bar.com"}, _context), do: {:error, :invalid_email}
  def handle(user, context), do: Blogs.Accounts.create_user(user, context)
end

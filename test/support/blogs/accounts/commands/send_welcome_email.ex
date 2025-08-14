defmodule Blogs.Accounts.Commands.SendWelcomeEmail do
  @moduledoc false
  use Sleeky.Command

  alias Blogs.Accounts.Values.UserId

  command(params: UserId)
end

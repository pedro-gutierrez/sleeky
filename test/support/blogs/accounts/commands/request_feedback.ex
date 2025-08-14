defmodule Blogs.Accounts.Commands.RequestFeedback do
  @moduledoc false
  use Sleeky.Command
  alias Blogs.Accounts.Values.UserId

  command params: UserId do
  end
end

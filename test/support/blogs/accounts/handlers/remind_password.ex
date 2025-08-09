defmodule Blogs.Accounts.Handlers.RemindPassword do
  @moduledoc false

  def execute(user_id, _context) do
    {:ok, user_id}
  end
end

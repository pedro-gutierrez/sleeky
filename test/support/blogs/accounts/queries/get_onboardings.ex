defmodule Blogs.Accounts.Queries.GetOnboardings do
  @moduledoc false
  use Sleeky.Query

  alias Blogs.Accounts.Onboarding

  query returns: Onboarding, many: true do
    sort by: :steps_pending, direction: :desc
  end
end

defmodule Blogs.Accounts.Onboarding do
  @moduledoc false
  use Sleeky.Model

  model do
    attribute :user_id, kind: :id, required: true
    attribute :steps_pending, kind: :integer, required: true
  end
end

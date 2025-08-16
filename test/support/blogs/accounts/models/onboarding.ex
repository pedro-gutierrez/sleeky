defmodule Blogs.Accounts.Onboarding do
  @moduledoc false
  use Sleeky.Model

  model do
    attribute :user_id, kind: :id, required: true
    attribute :steps_pending, kind: :integer, required: true

    unique fields: [:user_id] do
      on_conflict strategy: :merge
    end
  end
end

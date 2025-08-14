defmodule Sleeky.FlowTest do
  use Sleeky.DataCase

  alias Blogs.Accounts.Flows.Onboarding
  alias Blogs.Accounts.Values.UserId

  describe "execute/2" do
    test "Creates a model entry and enqueues jobs" do
      params = %UserId{user_id: uuid()}

      assert {:ok, onboarding} = Onboarding.execute(params)
      assert onboarding.user_id == params.user_id
      assert onboarding.steps_pending == 2
      assert_job_success(2)
    end
  end
end

defmodule Sleeky.JobTest do
  use Sleeky.DataCase

  alias Blogs.Publishing.Blog
  alias Sleeky.Job

  setup [:comments]

  describe "perform/1" do
    test "preloads models", %{blog: blog} do
      defmodule BlogTask do
        def execute(blog) do
          assert blog.author
        end
      end

      args = %{"model" => Blog, "id" => blog.id, "task" => BlogTask}
      assert :ok == Job.perform(%Oban.Job{args: args})
    end
  end
end

defmodule Sleeky.JobTest do
  use Sleeky.DataCase

  alias Blogs.Publishing
  alias Sleeky.Job

  setup [:comments]

  describe "perform/1" do
    test "preloads models", %{blog: blog} do
      defmodule BlogTask do
        def execute(blog) do
          assert blog.author
        end
      end

      args = %{"model" => Publishing.Blog, "id" => blog.id, "task" => BlogTask}
      assert :ok == Job.perform(%Oban.Job{args: args})
    end

    test "is transactional", %{blog: blog, post: post} do
      defmodule CreatePostTask do
        def execute(blog) do
          assert {:ok, _} =
                   Publishing.Post.create(
                     id: Ecto.UUID.generate(),
                     author_id: blog.author.id,
                     blog_id: blog.id,
                     published: true,
                     deleted: false,
                     title: "latest post",
                     locked: false,
                     published_at: DateTime.utc_now()
                   )

          {:error, :timeout}
        end
      end

      args = %{"model" => Publishing.Blog, "id" => blog.id, "task" => CreatePostTask}
      assert {:error, :timeout} == Job.perform(%Oban.Job{args: args})

      assert %{entries: [^post]} = Publishing.list_posts()
    end
  end
end

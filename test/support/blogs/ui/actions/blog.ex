defmodule Blogs.Ui.Actions.Blog do
  @moduledoc false

  def execute(%{"id" => "1"}), do: %{"id" => "1", "name" => "Blog"}
  def execute(_), do: {:error, :not_found}
end

defmodule MainView do
  @moduledoc false
  use Sleeky.Ui.View

  render do
    section id: "main" do
      p class: "title" do
        "Hero title"
      end

      label("Enter your username")
      input(type: "text")

      button do
        "Submit"
      end
    end
  end
end

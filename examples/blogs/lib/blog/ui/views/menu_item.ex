defmodule Blog.UI.Views.MenuItem do
  use Bee.UI.View

  render do
    a class: "navbar-item", "data-link": "{{ link }}" do
      {:slot, :label}
    end
  end
end

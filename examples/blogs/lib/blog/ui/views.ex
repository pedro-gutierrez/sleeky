defmodule Blog.UI.Views do
  use Bee.Views, schema: Blog.Schema

  def link(url, child) do
    {:a, ["data-link": url], [child]}
  end

  def menu_item(entity) do
    link("/#{entity.plural()}", entity.plural_label())
  end
end

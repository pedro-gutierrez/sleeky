defmodule Blog.UI.Index do
  use Bee.UI.View

  render do
    view Blog.UI.Html do
      body do
        view Blog.UI.Layout do
          menu do
            view(Blog.UI.Views.Menu)
          end

          breadcrumbs do
            view(Blog.UI.Views.Breadcrumbs)
          end

          notifications do
          end

          main do
            view(Blog.UI.Views.Entities)
          end
        end
      end
    end
  end
end

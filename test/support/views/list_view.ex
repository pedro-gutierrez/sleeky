defmodule ListView do
  use Sleeky.Ui.View

  render do
    ul do
      each :items do
        li "{{ item.title }}"
      end
    end
  end
end

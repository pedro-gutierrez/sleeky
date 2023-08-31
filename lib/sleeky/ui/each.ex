defmodule Sleeky.Ui.Each do
  @moduledoc """
  Provides with the ability to iterate over slots that are lists of items, and render a template for
    each of them.

  ```elixir
  defmodule MyApp.Ui.List do
    use Sleeky.View

    render do
      ul do
        each :items do
          li "{{ item.title }}"
        end
      end
    end
  end
  ```

  then


  ```elixir
  defmodule MyApp.Ui.IndexPage do
    use Sleeky.View

    alias MyApp.Ui.Layout

    render do
      view List do
        items do
          [[title: "Buy food"], [title: "Code Elixir"]]
        end
      end
    end
  end
  ```
  """

  defmodule Dsl do
    @moduledoc false

    @doc false
    def locals_without_parens, do: [each: :*]

    @doc false
    def tags, do: [:each]

    defmacro __using__(_opts) do
      quote do
        import Sleeky.Ui.Each.Dsl
      end
    end

    defmacro each(slot, do: template) do
      quote do
        {:each, [slot: unquote(slot)], [unquote(template)]}
      end
    end
  end

  defmodule Resolve do
    @moduledoc false

    defmacro __using__(_opts) do
      quote do
        def resolve({:each, [slot: slot], [template]}, args) do
          case slot!(slot, args) do
            items when is_list(items) ->
              Enum.map(items, fn item ->
                item = Enum.into(item, %{})
                resolve(template, %{item: item})
              end)

            other ->
              raise "Expecting a list for slot #{slot}. Got: #{inspect(other)}"
          end
        end
      end
    end
  end
end

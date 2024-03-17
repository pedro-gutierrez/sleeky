defmodule Sleeky.Ui.View.Dsl.Composition do
  @moduledoc """
  Provides with the ability to create compound views, using slots

  Compound views are simply views that depend on other views. This is useful in order to create layouts, eg:

  ```elixir
  defmodule MyApp.Ui.Layout do
    use Sleeky.View

    render do
      html do
        head do
        end
        body do
          div class: "main" do
            slot name: :main
          end
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
      view Layout do
        slot name: :main do
          h1 "It works!"
        end
      end
    end
  end
  ```

  In the above example the layout view defines a slot named `:main`.

  In addition to composition, this package provides with the ability to iterate over slots that are lists of items:

  ```elixir
  defmodule MyApp.Ui.List do
    use Sleeky.View

    render do
      ul do
        each slot: :items do
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
        slot name: :items do
          [[title: "Buy food"], [title: "Code Elixir"]]
        end
      end
    end
  end
  ```
  """
  use Diesel.Package,
    tags: [:view, :slot, :each]

  @impl true
  def compiler do
    quote do
      def compile({:slot, [], [name]}, ctx) do
        name
        |> slot_value!(ctx)
        |> compile(ctx)
      end

      def compile({:view, [], [view]}, ctx) do
        Code.ensure_compiled!(view)
        view.compile(ctx)
      end

      def compile({:view, [name: view], slots}, ctx) do
        Code.ensure_compiled!(view)

        slots =
          slots
          |> Enum.map(fn {:slot, [name: name], [content]} ->
            {name, compile(content, ctx)}
          end)
          |> Enum.into(%{})

        ctx = Map.merge(ctx, slots)
        view.compile(ctx)
      end

      def compile({:each, [name: slot], [template]}, ctx) do
        case slot_value!(slot, ctx) do
          items when is_list(items) ->
            Enum.map(items, &compile(template, %{item: Map.new(&1)}))

          other ->
            raise "Expecting a list for slot #{slot}. Got: #{inspect(other)}"
        end
      end

      defp slot_value!(name, ctx) do
        with nil <- Map.get(ctx, name) do
          raise "No value for slot #{inspect(name)} in #{inspect(ctx)}"
        end
      end
    end
  end
end

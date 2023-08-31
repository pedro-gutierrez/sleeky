defmodule Sleeky.Ui.Compound do
  @moduledoc """
  Provides with the ability to create compound views.

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
            slot :main
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
        main do
          h1 "It works!"
        end
      end
    end
  end
  ```

  In the above example the layout view defines a slot named `:main`.

  Then the index page provides a value for that slot. The resolution phase, which happens at compile
    time, is in charge of recursively going through all these dependencies and replacing slot
    definitions by their values, until we obtain a new view definition that no longer has any
    dependencies.
  """

  defmodule Dsl do
    @moduledoc false

    @doc false
    def locals_without_parens, do: [view: :*, slot: :*]

    @doc false
    def tags, do: [:view, :slot]

    defmacro __using__(_opts) do
      quote do
        import Sleeky.Ui.Compound.Dsl
      end
    end

    defmacro view(view) do
      quote do
        {:view, unquote(view), []}
      end
    end

    defmacro view(view, do: {:__block__, _, content}) when is_list(content) do
      content = for {slot, _, content} <- content, do: {slot, unwrap(content)}

      quote do
        {:view, unquote(view), unquote(content)}
      end
    end

    defmacro view(view, do: {slot, _, [[do: content]]}) do
      quote do
        {:view, unquote(view), [{unquote(slot), unquote(content)}]}
      end
    end

    defmacro view(view, do: {slot, _, content}) do
      quote do
        {:view, unquote(view), [{unquote(slot), unquote(content)}]}
      end
    end

    defmacro slot(name) do
      quote do
        {:slot, [], [unquote(name)]}
      end
    end

    def unwrap([[do: content]]), do: content
    def unwrap([content]), do: content
    def unwrap(content), do: content
  end

  defmodule Resolve do
    @moduledoc """
    Provides the support for resolving and transcluding view dependencies in a recursive manner
    """

    defmacro __using__(_opts) do
      quote do
        def resolve({:slot, name, [child]}, args) when is_atom(name) do
          case slot!(name, args) do
            items when is_list(items) ->
              Enum.map(items, fn item ->
                item = Enum.into(item, %{})
                resolve(child, item)
              end)
          end
        end

        def resolve({:slot, [], [name]}, args) when is_atom(name) do
          resolve({:slot, name}, args)
        end

        def resolve({:slot, name}, args) when is_atom(name) do
          name
          |> slot!(args)
          |> resolve(args)
        end

        def resolve({:entity, entity, children}, args) do
          args = Map.put(args, :__entity__, entity)
          resolve(children, args)
        end

        def resolve({:view, view}, args) do
          Code.ensure_compiled!(view)
          view.resolve(args)
        end

        def resolve({:view, [], [view]}, args) do
          Code.ensure_compiled!(view)
          view.resolve(args)
        end

        def resolve({:view, view, slots}, args) do
          Code.ensure_compiled!(view)
          slots = resolve_slots(slots, args)
          args = args |> Map.take([:__entity__]) |> Map.merge(slots)
          view.resolve(args)
        end

        defp resolve_slots(slots, args) do
          resolve_slots(slots, args, fn
            {name, _, value} -> {name, value}
            {name, value} -> {name, value}
          end)
        end

        defp resolve_slots(slots, args, fun) do
          slots
          |> resolve(args)
          |> case do
            args when is_list(args) -> args
            arg -> [arg]
          end
          |> Enum.map(fun)
          |> Enum.into(%{})
        end

        defp slot!(name, args) do
          with nil <- Map.get(args, name) do
            raise "No value for slot #{inspect(name)} in #{inspect(args)}"
          end
        end
      end
    end
  end
end

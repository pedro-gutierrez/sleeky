defmodule Sleeky.Ui.View do
  @moduledoc """
  A Sleeky UI is made of Sleeky views.

  Usage:

  ```elixir
  defmodule MyApp.Ui.SomeView do
    use Sleeky.Ui.View

    render do
      html do
        head do
          title "This is some nice title"
          meta charset: "utf-8"
        end

        body do
          h1 class: "title" do
            "It works!"
          end
        end
      end
    end
  end
  ```

  Views are expressed in pure Elixir, then compiled into an internal representation made of simple
    tuples nested one within another, quite similar to what Floki does. Views can be expressed in
    terms of other views. Resolving a view traverses all these dependencies and produces a final,
    single internal representation that no longer depends on anything. Finally, once resolved, a
    view gets rendered into plain html, in order to be served by a router.

  By default, all this process happens during compile time. In development mode however views
    are resolved at runtime.
  """
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Ui.View.Dsl,
    overrides: [div: 2],
    generators: [
      Sleeky.Ui.View.Generators.Html
    ],
    compilation_flags: [:strip_root]
end

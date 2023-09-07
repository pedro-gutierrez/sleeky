defmodule Mix.Tasks.Sleeky.Gen.Formatter do
  @shortdoc "Generates a new .formatter.exs for Sleeky"

  @moduledoc """
  Note: this is an internal tool and is not meant to be used by application developers.


  Usage:

      mix sleeky.gen.formatter

  """
  use Mix.Task

  import Mix.Generator

  @requirements ["compile"]

  @impl true
  def run(_argv) do
    assigns = [locals_without_parens: Sleeky.locals_without_parens()]

    create_file(".formatter.exs", formatter_template(assigns))
  end

  embed_template(:formatter, """
  locals_without_parens = [
  <%= for {fun, arity} <- @locals_without_parens do %>  <%= fun %>: :<%= arity %>,
  <% end %>]

  [
    inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
    locals_without_parens: locals_without_parens,
    import_deps: [:ecto, :ecto_sql, :plug, :diesel],
    export: [
      locals_without_parens: locals_without_parens
    ]
  ]
  """)
end

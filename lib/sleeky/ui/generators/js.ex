defmodule Sleeky.Ui.Generators.Js do
  @moduledoc """
  Generates the code that bundles all the bindings defined for a view into a single js file
  """
  @behaviour Diesel.Generator

  @impl true
  def generate(_, definition) do
    quote do
      def to_js do
        js =
          unquote(Macro.escape(definition))
          |> Enum.filter(fn {kind, _, _} -> kind == :bindings end)
          |> Enum.map(fn {_, [app: app], files} ->
            Enum.map(files, fn file ->
              path = Path.join("priv/bindings", file)
              app |> Application.app_dir(path) |> File.read!()
            end)
          end)
          |> List.flatten()
          |> Enum.join("\n")

        :sleeky
        |> Application.app_dir("priv/templates/ui.js")
        |> File.read!()
        |> EEx.eval_string(app_bindings: js)
      end
    end
  end
end

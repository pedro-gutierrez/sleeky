defmodule Mix.Tasks.Sleeky.Ui.Import do
  @moduledoc """
  A Mix task that imports raw html into a Sleeky view
  """

  use Mix.Task

  alias Sleeky.Ui.Import

  @shortdoc """
  A Mix task that imports raw html into a Sleeky view
  """

  @requirements ["compile"]

  @switches [
    module: :string
  ]

  @impl true
  def run(argv) do
    {opts, argv} = OptionParser.parse!(argv, strict: @switches)

    case argv do
      [] ->
        usage() |> Mix.raise()

      [html | _] ->
        module = opts |> Keyword.fetch!(:module) |> String.split(".") |> Module.concat()
        filename = Path.join(["lib", Macro.underscore(module) <> ".ex"])
        code = Import.view_module(html, module)

        File.write!(filename, code)
        Mix.shell().info("Written #{filename}")
    end
  end

  defp usage do
    """
    Expected a html string, please use:

        mix sleeky.ui.import --module SomeModule "<span>some html</span>"

    If you are trying to input a multiline html, you can use:

        mix sleeky.ui.import --module SomeModule "$(cat << EOM
        <div>
          <span>
            Some text
          </span>
        </div>
        EOM
        dquote cmdsubst> )"
    """
  end
end

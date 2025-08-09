defmodule Sleeky.Feature do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Feature.Dsl,
    parsers: [
      Sleeky.Feature.Parser
    ],
    generators: [
      Sleeky.Feature.Generator.Metadata,
      Sleeky.Feature.Generator.Roles,
      Sleeky.Feature.Generator.Graph,
      Sleeky.Feature.Generator.Helpers,
      Sleeky.Feature.Generator.CreateFunctions,
      Sleeky.Feature.Generator.UpdateActions,
      Sleeky.Feature.Generator.ReadActions,
      Sleeky.Feature.Generator.DeleteActions,
      Sleeky.Feature.Generator.Commands,
      Sleeky.Feature.Generator.Queries
    ]

  defstruct [:app, :name, :repo, scopes: [], models: [], handlers: [], commands: []]

  def allow(command, context) do
    if command.allowed?(context) do
      :ok
    else
      {:error, :unauthorized}
    end
  end
end

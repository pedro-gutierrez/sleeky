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
      Sleeky.Feature.Generator.Allow,
      Sleeky.Feature.Generator.Scope,
      Sleeky.Feature.Generator.Graph,
      Sleeky.Feature.Generator.Helpers,
      Sleeky.Feature.Generator.CreateActions,
      Sleeky.Feature.Generator.UpdateActions,
      Sleeky.Feature.Generator.ReadActions,
      Sleeky.Feature.Generator.DeleteActions,
      Sleeky.Feature.Generator.ListActions,
      Sleeky.Feature.Generator.Transaction,
      Sleeky.Feature.Generator.Commands
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

defmodule Sleeky.Endpoint.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Endpoint
  alias Sleeky.Endpoint.Mount

  @impl true
  def parse({:endpoint, _, children}, _) do
    mounts =
      for {:mount, opts, _} <- children do
        path = Keyword.fetch!(opts, :at)
        component = Keyword.fetch!(opts, :name)
        router = Module.concat(component, Router)

        %Mount{path: path, router: router}
      end

    %Endpoint{mounts: mounts}
  end
end

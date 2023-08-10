defmodule Sleeky.CodeReloader do
  @moduledoc """
  A simple code reloader, that watches for file changes an recompiles your project.

  By default, this feature is activated in development mode only
  """
  use GenServer

  @doc false
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  @filter_patterns [".ex"]
  @filter_events [:created, :modified]

  @impl true
  def init(_) do
    path = File.cwd!()
    {:ok, pid} = FileSystem.start_link(dirs: [path])
    FileSystem.subscribe(pid)
    {:ok, pid}
  end

  @impl true
  def handle_info({:file_event, pid, {path, events}}, pid) do
    if interested?(path, events), do: IEx.Helpers.recompile()

    {:noreply, pid}
  end

  def handle_info({:file_event, pid, :stop}, pid), do: {:noreply, pid}

  defp interested?(path, events) do
    Enum.any?(@filter_patterns, &String.contains?(path, &1)) &&
      Enum.any?(@filter_events, &Enum.member?(events, &1))
  end
end

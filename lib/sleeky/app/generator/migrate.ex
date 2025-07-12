defmodule Sleeky.App.Generator.Migrate do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(app, _opts) do
    quote do
      defmodule Migrate do
        @moduledoc false
        use Task

        @doc false
        def start_link(_), do: Task.start_link(__MODULE__, :run, [])

        @doc false
        def run do
          for repo <- unquote(app.module).repos() do
            {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
          end
        end
      end
    end
  end
end

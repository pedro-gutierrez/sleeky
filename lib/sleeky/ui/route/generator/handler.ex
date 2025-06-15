defmodule Sleeky.Ui.Route.Generator.Handler do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(route, _opts) do
    quote do
      defmodule Handler do
        use Plug.Builder

        @action unquote(route.action)
        @views unquote(Macro.escape(route.views))

        import Sleeky.Ui.Route.Helper

        plug(:execute)

        def execute(conn, _opts) do
          params = conn.params

          params
          |> @action.execute()
          |> result(conn, params, @views)
        end
      end
    end
  end
end

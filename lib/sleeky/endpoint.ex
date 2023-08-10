defmodule Sleeky.Endpoint do
  @moduledoc """
  A simple helper macro that sets up a bandit listener plugged to a router.

  Usage:

  ```
  defmodule MyApp.Endpoint do
    use Sleeky.Endpoint,
      otp_app: :my_app,
      router: MyApp.Router
  end
  ```

  All options supported by Bandit can be provided via config, eg:

  ```
  config :my_app, MyApp.Endpoint,
    scheme: :http,
    port: 8080
  ```
  """

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    router = Keyword.fetch!(opts, :router)

    quote do
      use Supervisor

      @doc false
      def start_link(opts), do: Supervisor.start_link(__MODULE__, opts)

      if Mix.env() == :dev do
        @default_children [Sleeky.CodeReloader]
      else
        @default_children []
      end

      @impl true
      def init(_opts) do
        bandit_opts =
          unquote(otp_app)
          |> Application.fetch_env!(__MODULE__)
          |> Keyword.put(:plug, unquote(router))

        Supervisor.init(
          [
            {Bandit, bandit_opts}
          ] ++ @default_children,
          strategy: :one_for_one
        )
      end
    end
  end
end

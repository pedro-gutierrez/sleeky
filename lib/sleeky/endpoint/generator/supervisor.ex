defmodule Sleeky.Endpoint.Generator.Supervisor do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_endpoint, opts) do
    caller_module = Keyword.fetch!(opts, :caller_module)
    otp_app = Keyword.fetch!(opts, :otp_app)
    router = Module.concat(caller_module, Router)

    quote do
      use Supervisor

      @doc false
      def router, do: unquote(router)

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

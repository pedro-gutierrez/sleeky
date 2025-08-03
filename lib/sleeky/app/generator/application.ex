defmodule Sleeky.App.Generator.Application do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(app, opts) do
    name = app.name
    otp_app = Keyword.fetch!(opts, :otp_app)

    quote do
      use Application

      @otp_app unquote(otp_app)
      @repos unquote(app.repos)
      @endpoints unquote(app.endpoints)
      @contexts unquote(app.contexts)
      @migrate __MODULE__.Migrate

      def repos, do: @repos
      def contexts, do: @contexts

      @impl true
      def start(_type, _args) do
        oban_config = Application.fetch_env!(@otp_app, Oban)

        extra = [
          @migrate,
          {Oban, oban_config}
        ]

        children = @repos ++ @endpoints ++ extra

        opts = [strategy: :one_for_one, name: unquote(name).Supervisor]
        Supervisor.start_link(children, opts)
      end
    end
  end
end

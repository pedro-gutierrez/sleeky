defmodule Sleeky.Endpoint.Generator.Router do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(endpoint, opts) do
    caller = Keyword.fetch!(opts, :caller_module)
    otp_app = Keyword.fetch!(opts, :otp_app)
    router_module = Module.concat(caller, Router)

    mounts =
      for %{path: path, router: router} <- endpoint.mounts do
        quote do
          forward(unquote(path), to: unquote(router))
        end
      end

    conn = var(:conn)

    quote do
      defmodule unquote(router_module) do
        use Plug.Router

        plug Sleeky.Plug.Logger
        plug(Plug.Static, at: "/assets", from: {unquote(otp_app), "priv/assets"})
        plug(:match)
        plug(:dispatch)

        get "/healthz" do
          send_resp(unquote(conn), 200, "")
        end

        unquote_splicing(mounts)
      end
    end
  end
end

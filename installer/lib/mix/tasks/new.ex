defmodule Mix.Tasks.Sleeky.New do
  @shortdoc "Creates a new Sleeky project"

  @moduledoc """
  Creates a new Sleeky project.

  It expects the path of the project as argument.

      mix sleeky.new PATH [--app APP] [--module MODULE]

  A project at the given PATH will be created. The
  application name and module name will be retrieved
  from the path, unless `--module` or `--app` is given.

  An `--app` option can be given in order to
  name the OTP application for the project.

  A `--module` option can be given in order
  to name the modules in the generated code skeleton.

  ## Examples

      mix sleeky.new hello_world

  Is equivalent to:

      mix sleeky.new hello_world --module HelloWorld
  """
  use Mix.Task

  import Mix.Generator

  @switches [
    app: :string,
    module: :string
  ]

  @impl true
  def run(argv) do
    {opts, argv} = OptionParser.parse!(argv, strict: @switches)

    case argv do
      [] ->
        Mix.raise("Expected PATH to be given, please use \"mix new PATH\"")

      [path | _] ->
        app = opts[:app] || Path.basename(Path.expand(path))
        check_application_name!(app, !opts[:app])
        mod = opts[:module] || Macro.camelize(app)
        check_mod_name_validity!(mod)
        check_mod_name_availability!(mod)

        unless path == "." do
          check_directory_existence!(path)
          File.mkdir_p!(path)
        end

        File.cd!(path, fn ->
          generate(app, mod, path)
        end)
    end
  end

  defp generate(app, mod, path) do
    mod_filename = Macro.underscore(mod)

    assigns = [
      app: app,
      mod: mod,
      mod_filename: mod_filename,
      version: get_version(System.version())
    ]

    create_file("README.md", readme_template(assigns))
    create_file(".formatter.exs", formatter_template(assigns))
    create_file("coveralls.json", coveralls_template(assigns))
    create_file(".gitignore", gitignore_template(assigns))
    create_file("mix.exs", mix_exs_template(assigns))
    create_file("Dockerfile", dockerfile_template(assigns))
    create_file(".envrc", envrc_template(assigns))
    create_file("envrc.sample", envrc_sample_template(assigns))

    create_directory("config")
    create_file("config/config.exs", config_template(assigns))
    create_file("config/dev.exs", dev_config_template(assigns))
    create_file("config/test.exs", test_config_template(assigns))
    create_file("config/prod.exs", prod_config_template(assigns))
    create_file("config/runtime.exs", runtime_config_template(assigns))

    create_directory("lib")
    create_file("lib/#{mod_filename}/application.ex", lib_app_template(assigns))
    create_file("lib/#{mod_filename}/repo.ex", lib_repo_template(assigns))
    create_file("lib/#{mod_filename}/auth.ex", lib_auth_template(assigns))
    create_file("lib/#{mod_filename}/endpoint.ex", lib_endpoint_template(assigns))
    create_file("lib/#{mod_filename}/router.ex", lib_router_template(assigns))
    create_file("lib/#{mod_filename}/put_user.ex", lib_put_user_template(assigns))
    create_file("lib/#{mod_filename}/rest.ex", lib_rest_template(assigns))
    create_file("lib/#{mod_filename}/schema.ex", lib_schema_template(assigns))
    create_file("lib/#{mod_filename}/schema/user.ex", lib_schema_user_template(assigns))
    create_file("lib/#{mod_filename}/ui.ex", lib_ui_template(assigns))
    create_file("lib/#{mod_filename}/ui/index.ex", lib_ui_index_template(assigns))

    create_directory("test/support")
    create_file("test/test_helper.exs", test_helper_template(assigns))
    create_file("test/support/#{mod_filename}_case.ex", test_case_template(assigns))
    create_file("test/user/create_test.exs", test_user_create_template(assigns))

    create_directory(".github/workflows")
    create_file(".github/workflows/ci.yml", ci_template(assigns))

    create_directory("priv/repo/migrations")

    """
    Your Sleeky project was created successfully.

    This generator relies on Direnv, so make sure you run "direnv allow" in order
    to setup your environment.

    You can use "mix" to compile it:

        #{cd_path(path)}mix deps.get
        mix compile

    Then initialise your database:

        createuser #{app} -d
        mix sleeky.migrations
        mix ecto.create
        mix ecto.migrate

    Finally, you can test with "mix test".

    Run "mix help" for more commands.


    Then, start your project with "iex -S mix".
    """
    |> user_info_with_urls()
    |> friendly_message()
    |> String.trim_trailing()
    |> Mix.shell().info()
  end

  defp user_info_with_urls(text) do
    text <>
      """

      Useful urls:

         * UI: http://localhost:8080/
         * REST api: http://localhost:8080/api
         * Redoc UI: http://localhost:8080/doc
         * OpenApi spec: http://localhost:8080/api/openapi.json
      """
  end

  defp friendly_message(text) do
    text <>
      """

      Have fun :)

      """
  end

  defp cd_path("."), do: ""
  defp cd_path(path), do: "cd #{path}\n    "

  defp check_application_name!(name, inferred?) do
    unless name =~ ~r/^[a-z][a-z0-9_]*$/ do
      Mix.raise(
        "Application name must start with a lowercase ASCII letter, followed by " <>
          "lowercase ASCII letters, numbers, or underscores, got: #{inspect(name)}" <>
          if inferred? do
            ". The application name is inferred from the path, if you'd like to " <>
              "explicitly name the application then use the \"--app APP\" option"
          else
            ""
          end
      )
    end
  end

  defp check_mod_name_validity!(name) do
    unless name =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/ do
      Mix.raise(
        "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect(name)}"
      )
    end
  end

  defp check_mod_name_availability!(name) do
    name = Module.concat(Elixir, name)

    if Code.ensure_loaded?(name) do
      Mix.raise("Module name #{inspect(name)} is already taken, please choose another name")
    end
  end

  defp check_directory_existence!(path) do
    msg = "The directory #{inspect(path)} already exists. Are you sure you want to continue?"

    if File.dir?(path) and not Mix.shell().yes?(msg) do
      Mix.raise("Please select another directory for installation")
    end
  end

  defp get_version(version) do
    {:ok, version} = Version.parse(version)

    "#{version.major}.#{version.minor}" <>
      case version.pre do
        [h | _] -> "-#{h}"
        [] -> ""
      end
  end

  embed_template(:readme, """
  # <%= @mod %>

  **TODO: Add description**
  <%= if @app do %>
  ## Installation

  If [available in Hex](https://hex.pm/docs/publish), the package can be installed
  by adding `<%= @app %>` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [
      {:<%= @app %>, "~> 0.1.0"}
    ]
  end
  ```

  Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
  and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
  be found at [https://hexdocs.pm/<%= @app %>](https://hexdocs.pm/<%= @app %>).
  <% end %>
  """)

  embed_template(:formatter, """
  locals_without_parens = [
    allow: 1,
    allow: 2,
    meta: 1,
    link: 1,
    slot: 1,
    roles: 1,
    schema: 1,
    scope: 2,
    title: 1,
    unique: 1,
    view: 1
  ]

  [
    inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
    locals_without_parens: locals_without_parens,
    export: [
      locals_without_parens: locals_without_parens
    ]
  ]
  """)

  embed_template(:coveralls, """
  {
    "skip_files": [
      "lib/<%= @mod_filename %>/release.ex",
      "lib/<%= @mod_filename %>/repo.ex",
      "test/support"
    ]
  }
  """)

  embed_template(:gitignore, """
  /_build/
  /cover/
  /deps/
  /doc/
  /.fetch
  erl_crash.dump
  *.ez
  *.tar
  /tmp/
  .elixir-ls
  .envrc
  """)

  embed_template(:dockerfile, """
  FROM hexpm/elixir:1.14.5-erlang-25.3.2.4-alpine-3.18.2 AS builder
  RUN apk add --no-cache --update bash git openssl
  ENV MIX_ENV=prod
  COPY config ./config
  COPY lib ./lib
  COPY mix.exs .
  COPY mix.lock .
  RUN mix local.rebar --force \\
      && mix local.hex --force \\
      && mix deps.get \\
      && mix release

  FROM alpine:3.18.2
  RUN apk add --no-cache openssl openssl ncurses-libs libstdc++
  WORKDIR /app
  COPY --from=builder _build/prod/rel/<%= @mod_filename %>/ .
  CMD ["/app/bin/<%= @mod_filename %>", "start"]
  """)

  embed_template(:mix_exs, """
  defmodule <%= @mod %>.MixProject do
    use Mix.Project

    def project do
      [
        app: :<%= @app %>,
        version: "0.1.0",
        elixir: "~> <%= @version %>",
        start_permanent: Mix.env() == :prod,
        deps: deps(),
        elixirc_paths: elixirc_paths(Mix.env()),
        aliases: aliases(),
        test_coverage: [tool: ExCoveralls],
        preferred_cli_env: [
          coveralls: :test
        ],
        dialyzer: [plt_add_apps: [:ex_unit]]
      ]
    end

    def aliases do
      [
        test: ["ecto.create --quiet", "ecto.migrate", "test"]
      ]
    end

    def elixirc_paths(:test), do: ["lib", "test/support"]
    def elixirc_paths(_), do: ["lib"]

    # Run "mix help compile.app" to learn about applications.
    def application do
      [
        extra_applications: [:logger, :sleeky],
        mod: {<%= @mod %>.Application, []}
      ]
    end

    # Run "mix help deps" to learn about dependencies.
    defp deps do
      [
        {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
        {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
        {:excoveralls, "~> 0.14", only: [:test]},
        {:sleeky, "~> 0.0.1"}
      ]
    end
  end
  """)

  embed_template(:envrc, """
  export DATABASE_URL=postgres://<%= @app %>@localhost/<%= @app %>
  export DATABASE_POOL_SIZE=5
  export LOG_LEVEL=info
  export PORT=8080
  """)

  embed_template(:envrc_sample, """
  export DATABASE_URL=postgres://<%= @app %>@localhost/<%= @app %>
  export DATABASE_POOL_SIZE=5
  export LOG_LEVEL=info
  export PORT=8080
  """)

  embed_template(:lib_app, """
  defmodule <%= @mod %>.Application do
    @moduledoc false

    use Application

    @impl true
    def start(_type, _args) do
      children = [
        <%= @mod %>.Repo,
        <%= @mod %>.Endpoint
      ]

      opts = [strategy: :one_for_one, name: <%= @mod %>.Supervisor]
      Supervisor.start_link(children, opts)
    end
  end
  """)

  embed_template(:lib_repo, """
  defmodule <%= @mod %>.Repo do
    @moduledoc false
    use Ecto.Repo, otp_app: :<%= @app %>, adapter: Ecto.Adapters.Postgres
  end
  """)

  embed_template(:lib_auth, """
  defmodule <%= @mod %>.Auth do
    @moduledoc false
    use Sleeky.Auth

    roles [:current_user, :roles]

    scope :owner do
      "**.user" == "current_user"
    end

    scope :self do
      "id" == "current_user.id"
    end
  end
  """)

  embed_template(:lib_endpoint, """
  defmodule <%= @mod %>.Endpoint do
    @moduledoc false
    use Sleeky.Endpoint, otp_app: :<%= @app %>, router: <%= @mod %>.Router
  end
  """)

  embed_template(:lib_router, """
  defmodule <%= @mod %>.Router do
    @moduledoc false
    use Sleeky.Router,
      otp_app: :<%= @app %>,
      plugs: [<%= @mod %>.PutUser]
  end
  """)

  embed_template(:lib_put_user, """
  defmodule <%= @mod %>.PutUser do
    @moduledoc false

    @behaviour Plug
    import Plug.Conn

    @impl true
    def init(opts), do: opts

    @impl true
    def call(conn, _opts) do
      # sample user
      assign(conn, :current_user, %{id: "123", roles: [:admin]})
    end
  end
  """)

  embed_template(:lib_rest, """
  defmodule <%= @mod %>.Rest do
    @moduledoc false
    use Sleeky.Rest

    schema <%= @mod %>.Schema
  end
  """)

  embed_template(:lib_schema, """
  defmodule <%= @mod %>.Schema do
    @moduledoc false
    use Sleeky.Schema

    entity(<%= @mod %>.Schema.User)
  end
  """)

  embed_template(:lib_schema_user, """
  defmodule <%= @mod %>.Schema.User do
    @moduledoc false
    use Sleeky.Entity

    attribute :email, :string do
    end

    unique :email

    action :list do
      allow :admin
    end

    action(:read) do
      allow :admin
    end

    action :create do
      allow :admin
    end

    action :update do
      allow :admin
    end

    action :delete do
      allow :admin
    end
  end
  """)

  embed_template(:lib_ui, """
  defmodule <%= @mod %>.UI do
    @moduledoc false
    use Sleeky.UI

    view <%= @mod %>.UI.Index
  end
  """)

  embed_template(:lib_ui_index, """
  defmodule <%= @mod %>.UI.Index do
    @moduledoc false
    use Sleeky.UI.View

    render do
      html do
        head do
          meta charset: "utf-8"
          title "Welcome to Sleeky"
        end

        body do
          h1 do
            "Welcome to Sleeky!"
          end

          p do
            "Sleek tested, Mother approved."
          end
        end
      end
    end
  end
  """)

  embed_template(:config, """
  import Config

  config :<%= @app %>, ecto_repos: [<%= @mod %>.Repo]
  config :sleeky, schema: <%= @mod %>.Schema

  config :logger, :console,
    format: "$time [$level] $message: $metadata\n",
    metadata: [:reason]

  import_config "\#{config_env()}.exs"
  """)

  embed_template(:dev_config, """
  import Config
  """)

  embed_template(:prod_config, """
  import Config
  """)

  embed_template(:test_config, """
  import Config

  config :logger, level: :warn

  config :<%= @app %>, <%= @mod %>.Repo,
    url: "postgres://<%= @app %>:<%= @app %>@localhost/<%= @app %>_test",
    pool: Ecto.Adapters.SQL.Sandbox

  config :<%= @app %>, <%= @mod %>.Port,
    scheme: :http,
    port: 8079
  """)

  embed_template(:runtime_config, """
  import Config

  if config_env() in [:dev, :prod] do
    config :logger,
      level: "LOG_LEVEL" |> System.fetch_env!() |> String.to_existing_atom()

    config :<%= @app %>, <%= @mod %>.Repo,
      url: System.fetch_env!("DATABASE_URL"),
      pool_size: "DATABASE_POOL_SIZE" |> System.fetch_env!() |> String.to_integer()

    config :<%= @app %>, <%= @mod %>.Endpoint,
      scheme: :http,
      port: "PORT" |> System.fetch_env!() |> String.to_integer()
  end
  """)

  embed_template(:test_helper, """
  ExUnit.start()
  Ecto.Adapters.SQL.Sandbox.mode(<%= @mod %>.Repo, :manual)
  """)

  embed_template(:test_case, """
  defmodule <%= @mod %>.Case do
    @moduledoc "A base template for all test cases"
    use ExUnit.CaseTemplate

    using do
      quote do
        use Plug.Test

        import Ecto
        import Ecto.Query
        import <%= @mod %>.Case

        alias Ecto.Adapters.SQL.Sandbox
        alias <%= @mod %>.Repo

        @options <%= @mod %>.Router.init([])

        setup tags do
          :ok = Sandbox.checkout(Repo)

          unless tags[:async] do
            Sandbox.mode(Repo, {:shared, self()})
          end

          :ok
        end

        defp get(path, opts \\\\ []), do: request(:get, path, opts)
        defp post(path, opts \\\\ []), do: request(:post, path, opts)
        defp put(path, opts \\\\ []), do: request(:put, path, opts)
        defp delete(path, opts \\\\ []), do: request(:delete, path, opts)

        defp post_json(path, data, opts \\\\ []) do
          method = opts[:method] || :post
          data = Jason.encode!(data)
          headers = opts[:headers] || %{}
          headers = Map.put(headers, "content-type", "application/json")

          request(method, path, headers: headers, params: data)
        end

        defp request(method, path, opts) do
          conn =
            method
            |> conn(path, opts[:params])
            |> with_req_headers(opts[:headers] || %{})
            |> <%= @mod %>.Router.call(@options)
        end

        defp with_req_headers(conn, headers) do
          Enum.reduce(headers, conn, fn {key, value}, conn ->
            put_req_header(conn, key, value)
          end)
        end

        defp json_response(conn, status \\\\ 200) do
          assert :sent == conn.state
          assert status == conn.status
          Jason.decode!(conn.resp_body)
        end
      end
    end
  end
  """)

  embed_template(:test_user_create, """
  defmodule <%= @mod %>.UserCreateTest do
    use <%= @mod %>.Case

    describe "POST /api/users" do
      test "creates a new user" do
        assert %{"id" => _, "email" => _} =
                 post_json("/api/users", %{email: "alice@example.com"})
                 |> json_response(201)
      end

      test "does not create the same user twice" do
        post_json("/api/users", %{email: "alice@example.com"})
        |> json_response(201)

        post_json("/api/users", %{email: "alice@example.com"})
        |> json_response(409)

        assert [%{"id" => _}] =
                 get("/api/users")
                 |> json_response()
      end
    end
  end
  """)

  embed_template(:ci, """
  name: CI
  on: push
  env:
    MIX_ENV: test
    DEPS_CACHE_VERSION: v1
    ELIXIR_VERSION: 1.14
    ERLANG_VERSION: 25.0
  jobs:
    build-and-test:
      runs-on: ubuntu-latest
      services:
        postgres:
          env:
            POSTGRES_DB: <%= @app %>_test
            POSTGRES_PASSWORD: <%= @app %>
            POSTGRES_USER: <%= @app %>
          image: postgres:13-alpine
          ports:
            - 5432:5432
          options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
      steps:
        - name: Checkout
          uses: actions/checkout@v2
        - name: Setup elixir
          uses: erlef/setup-beam@v1
          with:
            elixir-version: ${{ env.ELIXIR_VERSION }}
            otp-version: ${{ env.ERLANG_VERSION }}
        - name: Fetch Mix cache
          id: mix-cache
          uses: actions/cache@v2
          with:
            path: |
              deps
              _build
              !_build/${{ env.MIX_ENV }}/<%= @mod_filename %>
            key: ${{ runner.os }}-deps-erlang-${{ env.ERLANG_VERSION }}-elixir-${{ env.ELIXIR_VERSION }}-mix-${{ hashFiles('**/mix.lock') }}-${{ env.DEPS_CACHE_VERSION }}
        - name: Get dependencies
          if: steps.mix-cache.outputs.cache-hit != 'true'
          run: |
            mix local.rebar --force
            mix local.hex --force
            mix deps.get
        - name: Check Formatting
          run: mix format --check-formatted
        - name: Compile
          run: mix compile
        - name: Credo
          run: mix credo --strict
        - name: Run Tests
          run: mix test
  """)
end

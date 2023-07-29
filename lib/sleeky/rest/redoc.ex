defmodule Sleeky.Rest.Redoc do
  @moduledoc false

  import Sleeky.Inspector

  def ast(rest, _schema) do
    module_name = module(rest, RedocUI)

    quote do
      defmodule unquote(module_name) do
        @behaviour Plug
        import Plug.Conn

        @index_html """
        <!doctype html>
        <html>
          <head>
            <title>ReDoc</title
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link href="https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700" rel="stylesheet">
          </head>
          <body>
            <redoc spec-url="<%= spec_url %>"></redoc>
            <script src="https://cdn.jsdelivr.net/npm/redoc@latest/bundles/redoc.standalone.js"></script>
          </body>
        </html>
        """

        @impl true
        def init(opts) do
          [html: EEx.eval_string(@index_html, opts)]
        end

        @impl true
        def call(conn, html: html) do
          send_resp(conn, 200, html)
        end
      end
    end
  end
end

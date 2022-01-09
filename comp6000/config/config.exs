# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :comp6000,
  ecto_repos: [Comp6000.Repo],
  storage_directory_path: "local-storage",
  storage_file_extension: "json",
  completed_file_extension: "gzip",
  chunk_delimiter: ","

# Configures the endpoint
config :comp6000, Comp6000Web.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: Comp6000Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Comp6000.PubSub,
  live_view: [signing_salt: "ITAvskTW"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :comp6000, Comp6000.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    # ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    args:
      ~w(src/index.js src/index.css --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --loader:.svg=text --loader:.js=jsx --inject:src/react-shim.js),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

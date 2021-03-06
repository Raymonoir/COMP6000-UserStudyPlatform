import Config

config :bcrypt_elixir, :log_rounds, 1

config :comp6000,
  storage_path: "test/support/local-storage"

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :comp6000, Comp6000.Repo,
  username: "postgres",
  password: "postgres",
  database: "comp6000_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :comp6000, Comp6000Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Er6YneQ/Ez6n5+RviRKxHSFA42RF6w4SgtRUHN0zM7LamN1wxmXmAWS3BAdYv70k",
  server: false

# In test we don't send emails.
config :comp6000, Comp6000.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

if System.get_env("GITHUB_ACTIONS") do
  config :comp6000, Comp6000.Repo,
    username: "postgres",
    password: "postgresGHA"
end

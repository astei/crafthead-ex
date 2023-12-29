import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :crafthead, CraftheadWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "I1LpoFkGx/uBwMtlAZMNPXJBAj2/fMV+JZDVKBe5+Ru1WR7X6QDeE9PzEq7DYNjf",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

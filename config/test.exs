import Config

config :website, WebsiteWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "f8nxJCsOkGLCvoFAz5VfaHumeEZOKW/G0GyM7O9mqmTqssLzLuyXKp/c8JwVbMF4",
  server: true

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_test,
  otp_app: :website,
  endpoint: WebsiteWeb.Endpoint,
  playwright: [
    browser: :chromium,
    browser_launch_timeout: 10_000,
    trace: System.get_env("PLAYWRIGHT_TRACE", "false") in ~w(t true),
    trace_dir: "tmp",
    timeout: 5_000
  ]

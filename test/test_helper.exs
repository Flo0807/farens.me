Application.put_env(:phoenix_test, :base_url, WebsiteWeb.Endpoint.url())

ExUnit.configure(exclude: [playwright: true])
ExUnit.start()

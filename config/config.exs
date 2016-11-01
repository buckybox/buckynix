# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :buckynix,
  ecto_repos: [Buckynix.Repo]

# Configures the endpoint
config :buckynix, Buckynix.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Dt/OJYmJJo0eVOAa2Pt+vy+g56TfNI86S1Pe6WOEYKyDkhdMJdn3l0tLw+6RWyCG",
  render_errors: [view: Buckynix.ErrorView, accepts: ~w(html json json-api)],
  pubsub: [name: Buckynix.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :phoenix, :format_encoders,
  "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :money,
  default_currency: :EUR # XXX: workaround for https://github.com/liuggio/money/issues/30

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Buckynix.User,
  repo: Buckynix.Repo,
  module: Buckynix,
  logged_out_url: "/",
  email_from: {"Your Name", "yourname@example.com"},
  opts: [:rememberable, :invitable, :registerable, :trackable, :lockable, :recoverable, :authenticatable]

config :coherence, Buckynix.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "your api key here"
# %% End Coherence Configuration %%

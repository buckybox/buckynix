# Buckynix

## Status

This is my one-month hackathon trying to rebuild [Bucky Box](http://www.buckybox.com/) from scratch using Elixir and Elm.
This is about 40% complete for a rough MVP and 15% for a proper app.
I'm releasing it under the AGPL license.
I might or might not resume development at a later stage.
If you think it's a cool project and would like to help, please contact me at the email address used in Git commits.
I'd love to team up with you.

Dev note: Elm feels like a great fit for the frontend but I'm not sure about Elixir/Phoenix for the backend. I'd like to redo the backend and API using Haskell or similar.

## Usage

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
  * Run linter with `mix credo --strict`

## License

AGPLv3+

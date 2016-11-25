defmodule Buckynix.Api.SessionView do
  use JaSerializer.PhoenixView

  attributes [:email, :user_id]
end

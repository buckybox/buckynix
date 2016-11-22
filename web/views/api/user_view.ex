defmodule Buckynix.Api.UserView do
  use JaSerializer.PhoenixView

  attributes [:url, :name, :balance, :tags]
end

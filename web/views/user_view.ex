defmodule Buckynix.UserView do
  use Buckynix.Web, :view
  use JaSerializer.PhoenixView

  attributes [:url, :name, :balance, :tags]
end

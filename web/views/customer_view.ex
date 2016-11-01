defmodule Buckynix.CustomerView do
  use Buckynix.Web, :view
  use JaSerializer.PhoenixView

  attributes [:url, :name, :balance]
end

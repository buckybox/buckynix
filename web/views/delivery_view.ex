defmodule Buckynix.DeliveryView do
  use Buckynix.Web, :view
  use JaSerializer.PhoenixView

  attributes [:date, :user]
end

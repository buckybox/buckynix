defmodule Buckynix.Api.DeliveryView do
  use JaSerializer.PhoenixView

  defmodule UserSerializer do
    use JaSerializer.PhoenixView
    attributes [:url, :name]
  end

  attributes [:date]
  has_one :user, include: true, serializer: UserSerializer
end

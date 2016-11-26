defmodule Buckynix.Api.DeliveryView do
  use JaSerializer.PhoenixView

  defmodule UserSerializer do
    use JaSerializer.PhoenixView
    attributes [:url, :name]
  end

  defmodule AddressSerializer do
    use JaSerializer.PhoenixView
    attributes [:street] # FIXME
  end

  attributes [:id, :date, :address]

  has_one :user, include: true, serializer: UserSerializer
  # has_one :address, include: true, serializer: AddressSerializer

  def user(struct, _conn) do
    case struct.user do
      %Ecto.Association.NotLoaded{} ->
        # XXX: don't include user if not loaded - however we need to return this
        # empty struct so Elm won't ignore the delivery entirely
        %{data: %{type: "user", id: ""}}
      other -> other
    end
  end

  def address(struct, _conn) do
    IO.inspect struct.user

    case struct.user do
      Ecto.Association.NotLoaded -> "NO USER"
      user ->
        address = user.address

        case address do
        nil -> "NO ADDRESS"
        address -> address.street
      end
    end
  end
end

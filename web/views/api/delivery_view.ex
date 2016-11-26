defmodule Buckynix.Api.DeliveryView do
  use JaSerializer.PhoenixView

  defmodule UserSerializer do
    use JaSerializer.PhoenixView

    location "/users/:id"
    attributes [:name]
  end

  attributes [:id, :date, :address]

  has_one :user, include: true, serializer: UserSerializer

  def date(delivery, _conn) do
    Ecto.DateTime.to_date(delivery.date)
  end

  def user(delivery, _conn) do
    case delivery.user do
      %Ecto.Association.NotLoaded{} ->
        # XXX: don't include user if not loaded - however we need to return this
        # empty struct so Elm won't ignore the delivery entirely
        %{data: %{type: "user", id: ""}}
      other -> other
    end
  end

  def address(delivery, _conn) do
    case delivery.address do
      nil -> "NO ADDRESS"
      a -> a.street
    end
  end
end

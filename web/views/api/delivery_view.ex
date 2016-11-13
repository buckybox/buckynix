defmodule Buckynix.Api.DeliveryView do
  use JaSerializer.PhoenixView

  defmodule UserSerializer do
    use JaSerializer.PhoenixView
    attributes [:url, :name]
  end

  attributes [:id, :date]

  has_one :user, include: true, serializer: UserSerializer

  def user(struct, _conn) do
    case struct.user do
      %Ecto.Association.NotLoaded{} ->
        # XXX: don't include user if not loaded - however we need to return this
        # empty struct so Elm won't ignore the delivery entirely
        %{data: %{type: "user", id: ""}}
      other -> other
    end
  end
end

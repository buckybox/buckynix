defmodule Buckynix.NotificationChannel do
  use Phoenix.Channel

  alias Buckynix.Notification
  alias Buckynix.{Repo,User} # FIXME: shouldn't use in Channels??

  def join("notification:" <> "42", _message, socket) do
    {:ok, socket}
  end

  def join(_, _message, _socket) do
    {:error, %{reason: "Not your user ID"}}
  end

  def handle_in("fetch_notification", _message, socket) do
    user = Repo.get_by!(User, email: "bob@carrot.net")
    notifications = Repo.all(Notification)
    IO.inspect notifications

    first_notification = List.first(notifications)

    if first_notification do
      broadcast! socket, "broadcast_notification", %{body: first_notification.body}
    end

    {:noreply, socket}
  end

  # intercept ["fetch_notification"]

  # def handle_out("fetch_notification", payload, socket) do
  #   push socket, "fetch_notification", payload
  #   {:noreply, socket}
  # end
end

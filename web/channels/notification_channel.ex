defmodule Buckynix.NotificationChannel do
  use Buckynix.Web, :channel

  alias Buckynix.Notification
  alias Buckynix.{Repo,User} # FIXME: shouldn't use in Channels??

  def join("notification:" <> "42", params, socket) do
    send(self, {:after_join, params})
    {:ok, assign(socket, :user_id, 1)}
  end

  def join(_, _message, _socket) do
    {:error, %{reason: "Not your user ID"}}
  end

  def handle_info({:after_join, _params}, socket) do
    user_id = socket.assigns.user_id

    first_notification = Repo.one(
      from n in Notification,
        where: n.user_id == ^user_id,
        order_by: [asc: n.inserted_at],
        limit: 1
    )

    if first_notification do
      push socket, "push_notification", %{body: first_notification.body}
    end

    {:noreply, socket}
  end

  # def handle_in("fetch_notification", _message, socket) do
  #   user = Repo.get_by!(User, email: "bob@carrot.net")
  #   notifications = Repo.all(Notification)
  #   IO.inspect notifications

  #   first_notification = List.first(notifications)

  #   if first_notification do
  #     broadcast! socket, "broadcast_notification", %{body: first_notification.body}
  #   end

  #   {:noreply, socket}
  # end

  # intercept ["fetch_notification"]

  # def handle_out("fetch_notification", payload, socket) do
  #   push socket, "fetch_notification", payload
  #   {:noreply, socket}
  # end
end

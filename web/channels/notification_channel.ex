defmodule Buckynix.NotificationChannel do
  use Buckynix.Web, :channel

  alias Buckynix.Notification
  alias Buckynix.User

  def join("notification:42", params, socket) do
    send(self, {:after_join, params})
    user_id = Repo.one(from u in User, limit: 1).id # FIXME
    {:ok, assign(socket, :user_id, user_id)}
  end

  def join(_, _message, _socket) do
    {:error, %{reason: "No such topic"}}
  end

  def handle_info({:after_join, _params}, socket) do
    user_id = socket.assigns.user_id

    query = from n in Notification,
      where: n.user_id == ^user_id,
      order_by: [asc: n.inserted_at],
      select: [:body]

    notifications = query |> Repo.all
    first_notification = query |> limit(1) |> Repo.one

    if first_notification do
      push socket, "push_notification", %{
        body: first_notification.body,
        count: length(notifications)
      }
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

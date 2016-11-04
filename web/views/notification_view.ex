defmodule Buckynix.NotificationView do
  use Buckynix.Web, :view

  def render("index.json", %{notifications: notifications}) do
    %{data: render_many(notifications, Buckynix.NotificationView, "notification.json")}
  end

  def render("show.json", %{notification: notification}) do
    %{data: render_one(notification, Buckynix.NotificationView, "notification.json")}
  end

  def render("notification.json", %{notification: notification}) do
    %{id: notification.id,
      user_id: notification.user_id,
      body: notification.body}
  end
end

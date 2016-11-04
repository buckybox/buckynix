defmodule Buckynix.NotificationController do
  use Buckynix.Web, :controller

  alias Buckynix.Notification

  def index(conn, _params) do
    notifications = Repo.all(Notification)
    render(conn, "index.json", notifications: notifications)
  end

  def create(conn, %{"notification" => notification_params}) do
    changeset = Notification.changeset(%Notification{}, notification_params)

    case Repo.insert(changeset) do
      {:ok, notification} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", notification_path(conn, :show, notification))
        |> render("show.json", notification: notification)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Buckynix.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    notification = Repo.get!(Notification, id)
    render(conn, "show.json", notification: notification)
  end

  def update(conn, %{"id" => id, "notification" => notification_params}) do
    notification = Repo.get!(Notification, id)
    changeset = Notification.changeset(notification, notification_params)

    case Repo.update(changeset) do
      {:ok, notification} ->
        render(conn, "show.json", notification: notification)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Buckynix.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    notification = Repo.get!(Notification, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(notification)

    send_resp(conn, :no_content, "")
  end
end

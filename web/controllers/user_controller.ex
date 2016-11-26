defmodule Buckynix.UserController do
  use Buckynix.Web, :controller

  alias Buckynix.{User}

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = (from u in User, preload: [:account, :address])
         |> Repo.get!(id)

    account = user.account
    address = user.address
    orders = []

    render(conn, "show.html", user: user, account: account, address: address, orders: orders)
  end

  def edit(conn, %{"id" => id}) do
    user = (from u in User,
      preload: [:address]
    ) |> Repo.get!(id)

    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = (from u in User,
      preload: [:address]
    ) |> Repo.get!(id)

    changeset =
      User.changeset(user, user_params)
      |> Ecto.Changeset.cast_assoc(:address, required: false)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    User.changeset(user, %{archived_at: Ecto.DateTime.utc})
    |> Repo.update!

    conn
    |> put_flash(:info, "User archived successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end

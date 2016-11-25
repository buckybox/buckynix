defmodule Buckynix.Api.SessionController do
  use Buckynix.Web, :controller

  alias Buckynix.User

  def create(conn, %{"data" => %{"attributes" => credentials}}) do
    email = Map.get(credentials, "email")
    password = Map.get(credentials, "password")

    session = %{email: email, user_id: nil}
    user = Repo.one(from u in User, where: u.email == ^email)

    if user do
      correct_password = Comeonin.Bcrypt.checkpw(password, user.password_hash)

      if correct_password do
        session = Map.put(session, :user_id, user.id)

        conn
        |> put_session("user_id", user.id)
        |> put_status(:created)
        |> render("show.json-api", data: session)
      else
        conn
        |> put_status(:ok)
        |> render("show.json-api", data: session)
      end
    else
      create_user(email)

      conn
        |> put_status(:accepted)
        |> render("show.json-api", data: session)
    end
  end

  defp create_user(email) do
    random_password = :crypto.strong_rand_bytes(64) |> Base.url_encode64

    changeset = User.changeset(%User{},
      %{email: email, name: "Guest", password: random_password}
    )

    Repo.insert!(changeset)
  end
end

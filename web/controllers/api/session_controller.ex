defmodule Buckynix.Api.SessionController do
  use Buckynix.Web, :controller

  alias Buckynix.User

  def create(conn, %{"data" => %{"attributes" => credentials}}) do
    email = Map.get(credentials, "email")
    password = Map.get(credentials, "password")

    user = Repo.one(from u in User, where: u.email == ^email)

    if user do
      correct_password = User.checkpw(password, user.password_hash)

      if !correct_password do
        conn
        |> put_status(:forbidden)
        |> halt
      end

      session = %{email: email}
      conn
      |> put_status(:created)
      |> render("show.json-api", session: session)

      # case Repo.update(changeset) do
      #   {:ok, session} ->
      #     conn
      #     |> put_status(:created)
      #     |> render("show.json", session: session)
      #   {:error, changeset} ->
      #     conn
      #     |> put_status(:unprocessable_entity)
      #     |> render("error.json", changeset: changeset)
      # end
    else
      create_user(email)

      session = %{email: email}
      conn
        |> put_status(:accepted)
        |> render("show.json-api", session: session)
    end
  end

  defp create_user(email) do
    changeset = User.changeset(%User{}, %{email: email})

    Repo.insert!(changeset)
  end
end

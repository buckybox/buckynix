defmodule Buckynix.Router do
  use Buckynix.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  pipeline :api do
    plug :accepts, ["json-api"]
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  scope "/" do
    pipe_through :browser
    coherence_routes
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", Buckynix do
    pipe_through :browser
    get "/", PageController, :index

    # Add public routes below
    get "/", PageController, :index
  end

  scope "/", Buckynix do
    pipe_through :protected

    # Add protected routes below
    get "/customers/tag/:tag", CustomerController, :tag
    get "/customers/search", CustomerController, :search
    resources "/customers", CustomerController do
      resources "/orders", OrderController
    end
  end

  scope "/api", Buckynix do
    pipe_through :api

    resources "/transactions", TransactionController, only: [:index, :create]
  end
end

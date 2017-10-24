defmodule PackexWeb.Router do
  use PackexWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipe_through :api

  resources "/packages", PackexWeb.PackagesController, only: [:create, :show, :update, :delete, :index]
end


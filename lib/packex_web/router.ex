defmodule PackexWeb.Router do
  use PackexWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipe_through :api

  resources "/packages", PackexWeb.PackagesController, only: [:create, :show, :update, :delete, :index]

  def swagger_info() do
    %{info: %{version: "1.0", title: "Packex - A Web Service for Manageging Packages of Products"}}
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :packex, swagger_file: "swagger.json", disable_validator: true
  end
end


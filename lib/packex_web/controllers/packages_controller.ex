defmodule PackexWeb.PackagesController do
  use PackexWeb, :controller
  use PhoenixSwagger

  swagger_path(:create) do
    post "/packages"
    description "Create a Package"
    response 201, "Created"
  end
  def create(conn, params) do
    id =
      params
      |> populate_products()
      |> populate_price("USD")
      |> Packex.Store.create()
    conn
    |> put_resp_header("location", PackexWeb.Router.Helpers.packages_path(conn, :show, id))
    |> send_resp(201, "")
  end

  swagger_path(:show) do
    get "/packages/{id}"
    description "Get a Package"
    parameters do
      id :path, :string, "Package identifier", required: true
    end
    response 200, "Ok"
    response 404, "Not found"
  end
  def show(conn, %{"id" => id} = params) do
    case Packex.Store.read(id) do
      nil -> send_resp(conn, 404, "")
      package -> json(conn, populate_price(package, Map.get(params, "currency", "USD")))
    end
  end

  swagger_path(:update) do
    put "/packages/{id}"
    description "Update a Package"
    parameters do
      id :path, :string, "Package identifier", required: true
    end
    response 200, "Ok"
    response 404, "Not found"
  end
  def update(conn, params) do
    params =
      params
      |> populate_products()
      |> populate_price("USD")
    case Packex.Store.update(params) do
      true -> send_resp(conn, 204, "")
      false -> send_resp(conn, 404, "")
    end
  end

  swagger_path(:delete) do
    delete "/packages/{id}"
    description "Delete a Package"
    parameters do
      id :path, :string, "Package identifier", required: true
    end
    response 204, "No content"
    response 404, "Not found"
  end
  def delete(conn, %{"id" => id}) do
    case Packex.Store.delete(id) do
      true -> send_resp(conn, 204, "")
      false -> send_resp(conn, 404, "")
    end
  end

  swagger_path(:index) do
    get "/packages"
    description "Get All Packages"
    response 200, "Ok"
  end
  def index(conn, _params), do: json(conn, Packex.Store.read_all())

  # Private functions

  defp populate_products(package) do
    Map.replace(package,
                "products",
                Enum.map(Map.get(package, "products"),
                         &Map.merge(&1, Packex.ProductService.product_info(Map.get(&1, "id")))))
  end

  defp populate_price(package, currency) do
    Map.put(package,
            "price",
            Packex.ExchangeRateService.exchange_rate(currency) *
              Enum.reduce(Map.get(package, "products"), 0.0, &(Map.get(&1, "usdPrice", 0.0) + &2)))
  end
end


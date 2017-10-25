defmodule Packex.ProductService do
  use GenServer

  @moduledoc """
  A product information server.

  Note, this server uses an external service to obtain the product information. The external service frequently delays
  its responses which causes calls to timeout.
  """

  @auth_header ["Authorization": "Basic " <> Base.encode64("user" <> ":" <> "pass")]
  @url_base "https://product-service.herokuapp.com/api/v1/products/"

  # Client API

  @doc """
  Start the Product Service server.
  """
  def start_link(_arg), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @doc """
  The product information associated with `id` (or `nil` if such information does not exist).

  We cache this information, fetching it from the external product service only if necessary (the information provided
  by the external service is only ever added to).
  """
  def product_info(id), do: GenServer.call(__MODULE__, {:product_info, id})

  # Callbacks

  def init(_arg), do: {:ok, %{}}

  def handle_call({:product_info, id}, _from, products) do
    case Map.has_key?(products, id) do
      true -> {:reply, Map.get(products, id), products}
      _ ->
        case get_product(id) do
          nil -> {:reply, nil, products}
          product -> {:reply, product, Map.put(products, id, product)}
        end
    end
  end

  # Private Functions

  defp get_product(id) do
    case HTTPoison.get(@url_base <> id, @auth_header) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> Poison.Parser.parse!(body)
      _ -> nil
    end
  end
end


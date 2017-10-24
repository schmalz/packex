defmodule Packex.Supervisor do
  use Supervisor

  @moduledoc """
  Top level supervisor for the `packex` application.
  """

  # Client API

  def start_link(arg), do: Supervisor.start_link(__MODULE__, arg, name: __MODULE__)

  # Callbacks

  def init(_arg) do
    children = [{Packex.ExchangeRateService, nil},
                {Packex.ProductService, nil},
                {Packex.Store, nil},
                {PackexWeb.Endpoint, []}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end


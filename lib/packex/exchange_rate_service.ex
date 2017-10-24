defmodule Packex.ExchangeRateService do
  use GenServer

  @moduledoc """
  A currency exchange rate server. Note, the base currency is USD (this may change to an `init/1` parameter in the
  future).
  
  """

  @url_base "http://api.fixer.io/latest?base=USD&symbols="

  # Client API

  def start_link(_arg), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @doc """
  The lastest exchange rate for `currency` (or 1.0 if such information does not exist).
  """
  def exchange_rate(currency), do: GenServer.call(__MODULE__, {:exchange_rate, currency})

  # Callbacks

  def init(_arg), do: {:ok, nil}

  @doc """
  Retrieve the exchange rate for `currency` against the base currency `USD`.
  """
  def handle_call({:exchange_rate, currency}, _from, _data) do
    case get_rate(currency) do
      nil -> {:reply, 1.0, nil}
      rate -> {:reply, rate, nil}
    end
  end

  # Private Functions

  defp get_rate(currency) do
    case HTTPoison.get(@url_base <> currency) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Poison.Parser.parse!()
        |> Map.get("rates")
        |> Map.get(currency)
      _ -> nil
    end
  end
end


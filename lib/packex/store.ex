defmodule Packex.Store do
  use GenServer

  @moduledoc """
  A simple store of packages.
  """

  # Client API

  def start_link(_arg), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def create(package), do: GenServer.call(__MODULE__, {:create, package})

  def read(id), do: GenServer.call(__MODULE__, {:read, id})

  def update(package), do: GenServer.call(__MODULE__, {:update, package})

  def delete(id), do: GenServer.call(__MODULE__, {:delete, id})

  def read_all(), do: GenServer.call(__MODULE__, :read_all)

  # Callbacks

  def init(_arg), do: {:ok, %{}}

  def handle_call({:create, package}, _from, packages) do
    id = UUID.uuid4()
    {:reply, id, Map.put(packages, id, Map.put(package, "id", id))}
  end
  def handle_call({:read, id}, _from, packages), do: {:reply, Map.get(packages, id), packages}
  def handle_call({:update, %{"id" => id} = package}, _from, packages) do
    case Map.has_key?(packages, id) do
      true -> {:reply, true, Map.replace(packages, id, package)}
      _ -> {:reply, false, packages}
    end
  end
  def handle_call({:delete, id}, _from, packages) do
    case Map.has_key?(packages, id) do
      true -> {:reply, true, Map.delete(packages, id)}
      _ -> {:reply, false, packages}
    end
  end
  def handle_call(:read_all, _from, packages), do: {:reply, Map.values(packages), packages}
end


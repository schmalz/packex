defmodule Packex.Application do
  use Application

  def start(_type, _args) do
    Packex.Supervisor.start_link(nil)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PackexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

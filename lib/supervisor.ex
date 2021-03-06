defmodule ExBanking.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: ExBanking.DynamicSupervisor},
      {Registry, keys: :unique, name: Registry.ExBanking}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end

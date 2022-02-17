defmodule ExBanking.User do
  use GenServer

  alias __MODULE__

  @impl true
  def start_link(user) do
    name = String.to_atom(user)
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @spec create_user(user :: String.t) :: :ok | {:error, :user_already_exists}
  def create_user(user) do
    case DynamicSupervisor.start_child(ExBanking.DynamicSupervisor, %{id: __MODULE__, start: {User, :start_link, [user]}})  do
      {:ok, _} ->
        :ok
      _ ->
        {:error, :user_already_exists}
    end
  end
end

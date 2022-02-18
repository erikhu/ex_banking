defmodule ExBanking.User do
  use GenServer

  alias __MODULE__

  @impl true
  def start_link(user) do
    GenServer.start_link(__MODULE__, {:ok, user}, name: via_name(user))
  end

  @impl true
  def init({:ok, user}) do
    {:ok, %{"user" => user, "wallet" => %{"currencies" => %{}}}}
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

  @spec get_user(String.t) :: {:ok, pid()} | {:error, :user_does_not_exist}
  def get_user(user) do
    case Registry.lookup(Registry.ExBanking, user) do
      [{pid, :ok}] ->
        {:ok, pid}
      _ ->
        {:error, :user_does_not_exist}
    end
  end

  @spec deposit(pid(), number(), String.t) :: {:ok, number()} | {:error, :too_many_requests_to_user}
  def deposit(pid, amount, currency) do
    GenServer.call(pid, {:deposit, %{amount: amount, currency: currency}})
  end

  defp via_name(user) do
    {:via, Registry, {Registry.ExBanking, user, :ok}}
  end

  @impl true
  def handle_call({:deposit, %{amount: amount, currency: currency}}, _from, state) do
    new_amount = Map.get(state["wallet"]["currencies"], currency, 0) + amount
    currencies = Map.put(state["wallet"]["currencies"], currency, new_amount)
    wallet = Map.put(state["wallet"], "currencies", currencies)
    state = Map.put(state, "wallet", wallet)
    {:reply, {:ok, new_amount}, state}
  end
end

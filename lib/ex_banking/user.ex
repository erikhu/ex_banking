defmodule ExBanking.User do
  use GenServer

  alias __MODULE__

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
        {:error, :user_already_exist}
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
  def get_user(user, custom_error) do
    case get_user(user) do
      {:ok, pid} ->
        {:ok, pid}
      _ ->
        {:error, custom_error}
    end
  end

  @spec deposit(pid(), number(), String.t) :: {:ok, number()} | {:error, :too_many_requests_to_user}
  def deposit(pid, amount, currency) do
    case validate_too_many_requests(pid) do
      :ok ->
        GenServer.call(pid, {:deposit, %{amount: Float.round(amount/1, 2), currency: currency}})
      error ->
        error
    end
  end

  @spec withdraw(pid(), number(), String.t) :: {:ok, number()} | {:error, :not_enough_money | :too_many_requests_to_user}
  def withdraw(pid, amount, currency) do
    case validate_too_many_requests(pid) do
      :ok ->
        GenServer.call(pid, {:withdraw, %{amount: Float.round(amount/1, 2), currency: currency}})
      error ->
        error
    end
  end

  @spec get_balance(pid(), binary()) :: {:ok, balance :: number} | {:error, :too_many_requests_to_user}
  def get_balance(pid, currency) do
    case validate_too_many_requests(pid) do
      :ok ->
        GenServer.call(pid, {:get_balance, %{currency: currency}})
      error ->
        error
    end
  end

  @spec send(pid(), pid(), number(), binary()) :: {:ok, from_user_balance :: number(), to_user_balance :: number()} | {:error, :not_enough_money | :too_many_requests_to_sender | :too_many_requests_to_receiver}
  def send(pid_sender, pid_receiver, amount, currency) do
    with :ok <- validate_too_many_requests(pid_sender, :too_many_requests_to_sender),
         :ok <- validate_too_many_requests(pid_receiver, :too_many_requests_to_receiver),
         {:ok, sender_balance} <- withdraw(pid_sender, amount, currency),
         {:ok, receiver_balance} <- deposit(pid_receiver, amount, currency)
      do
      {:ok, sender_balance, receiver_balance}
    end
  end

  defp via_name(user) do
    {:via, Registry, {Registry.ExBanking, user, :ok}}
  end

  @spec validate_too_many_requests(pid()) :: :ok | {:error, :too_many_requests_to_user}
  @spec validate_too_many_requests(pid(), atom()) :: :ok | {:error, atom()}
  defp validate_too_many_requests(pid) do
    {:message_queue_len, n} = Process.info(pid, :message_queue_len)
    if n >= 10 do
      {:error, :too_many_requests_to_user}
    else
      :ok
    end
  end
  defp validate_too_many_requests(pid, custom_message) do
    case validate_too_many_requests(pid) do
      :ok ->
        :ok
      _ ->
        {:error, custom_message}
    end
  end

  @impl true
  def handle_call({:deposit, %{amount: amount, currency: currency}}, _from, state) do
    new_amount = Float.round(Map.get(state["wallet"]["currencies"], currency, 0.00)/1 + amount, 2)
    currencies = Map.put(state["wallet"]["currencies"], currency, new_amount)
    wallet = Map.put(state["wallet"], "currencies", currencies)
    state = Map.put(state, "wallet", wallet)
    {:reply, {:ok, new_amount}, state}
  end

  @impl true
  def handle_call({:withdraw, %{amount: amount, currency: currency}}, _from, state) do
    new_amount = Float.round(Map.get(state["wallet"]["currencies"], currency, 0.00)/1 - amount, 2)
    currencies = Map.put(state["wallet"]["currencies"], currency, new_amount)
    wallet = Map.put(state["wallet"], "currencies", currencies)
    new_state = Map.put(state, "wallet", wallet)
    if new_amount >= 0 do
      {:reply, {:ok, new_amount}, new_state}
    else
      {:reply, {:error, :not_enough_money}, state}
    end
  end

  @impl true
  def handle_call({:get_balance, %{currency: currency}}, _from, state) do
    {:reply, {:ok, Map.get(state["wallet"]["currencies"], currency, 0.00)}, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end
end

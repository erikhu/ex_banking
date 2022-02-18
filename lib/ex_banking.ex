defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """

  alias ExBanking.User

  @spec deposit(user :: String.t, amount :: number, currency :: String.t) ::
  {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with :ok <- validate_arguments([is_bitstring(user), is_number(amount), is_bitstring(currency), amount >= 0]),
         {:ok, pid} <- User.get_user(user) do
      User.deposit(pid, amount, currency)
    end
  end

  @spec create_user(user :: String.t) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
    with :ok <- validate_arguments([is_bitstring(user)]) do
      User.create_user(user)
    end
  end

  @spec withdraw(user :: String.t, amount :: number, currency :: String.t) ::
  {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    with :ok <- validate_arguments([is_bitstring(user), is_number(amount), is_bitstring(currency), amount >= 0]) ,
         {:ok, pid} <- User.get_user(user) do
      User.withdraw(pid, amount, currency)
    end
  end

  @spec get_balance(user :: String.t, currency :: String.t) ::
  {:ok, balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
  end

  @spec send(from_user :: String.t, to_user :: String.t, amount :: number, currency :: String.t) ::
  {:ok, from_user_balance :: number, to_user_balance :: number} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) do
  end

  defp validate_arguments(arguments) do
    if Enum.find_value(arguments, false, fn arg -> not arg end) do
      {:error, :wrong_arguments}
    else
      :ok
    end
  end
end

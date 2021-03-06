defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """

  alias ExBanking.User

  @spec deposit(user :: String.t, amount :: number, currency :: String.t) ::
  {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with :ok <- validate_arguments([is_binary(user), is_number(amount), is_binary(currency), amount >= 0]),
         {:ok, pid} <- User.get_user(user) do
      User.deposit(pid, amount, currency)
    end
  end

  @spec create_user(user :: String.t) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
    with :ok <- validate_arguments([is_binary(user)]) do
      User.create_user(user)
    end
  end

  @spec withdraw(user :: String.t, amount :: number, currency :: String.t) ::
  {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    with :ok <- validate_arguments([is_binary(user), is_number(amount), is_binary(currency), amount >= 0]) ,
         {:ok, pid} <- User.get_user(user) do
      User.withdraw(pid, amount, currency)
    end
  end

  @spec get_balance(user :: String.t, currency :: String.t) ::
  {:ok, balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with :ok <- validate_arguments([is_binary(user), is_binary(currency)]) ,
         {:ok, pid} <- User.get_user(user) do
      User.get_balance(pid, currency)
    end
  end

  @spec send(from_user :: String.t, to_user :: String.t, amount :: number, currency :: String.t) ::
  {:ok, from_user_balance :: number, to_user_balance :: number} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) do
    with :ok <- validate_arguments([is_binary(from_user), is_binary(to_user), is_binary(currency), is_number(amount), amount >= 0]),
         {:ok, pid_sender} <- User.get_user(from_user, :sender_does_not_exist),
         {:ok, pid_receiver} <- User.get_user(to_user, :receiver_does_not_exist) do
      User.send(pid_sender, pid_receiver, amount, currency)
    end
  end

  defp validate_arguments(arguments) do
    if Enum.find_value(arguments, false, fn arg -> not arg end) do
      {:error, :wrong_arguments}
    else
      :ok
    end
  end
end

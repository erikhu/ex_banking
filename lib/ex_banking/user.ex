defmodule ExBanking.User do
  @spec create_user(user :: String.t) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
  end

  @spec get_user(user :: String.t) :: {:ok, resource} | {:error, :user_does_not_exist}
  def get_user(user) do
  end
end

defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  alias ExBanking
  alias ExBanking.User

  test "create user with wrong arguments" do
    assert ExBanking.create_user(0) == {:error, :wrong_arguments}
    assert ExBanking.create_user(%{}) == {:error, :wrong_arguments}
  end

  test "create user that already exists" do
    assert ExBanking.create_user("vitaly") == :ok
    assert ExBanking.create_user("vitaly") == {:error, :user_already_exist}
  end

  test "deposit amount with wrong arguments" do
    ExBanking.create_user("marta")
    assert ExBanking.deposit("marta", -1, "usd") == {:error, :wrong_arguments}
    assert ExBanking.deposit("marta", "1", "usd") == {:error, :wrong_arguments}
  end

  test "deposit amount that user does not exists" do
    assert ExBanking.deposit("martin", 1, "usd") == {:error, :user_does_not_exist}
  end

  test "deposit amount user too many requests" do
    ExBanking.create_user("juancho")
    {:ok, pid} = User.get_user("juancho")
    for _index <- 0..9 do
      send(pid, %{})
    end
    assert ExBanking.deposit("juancho", 1, "usd") == {:error, :too_many_requests_to_user}
  end

  test "deposit amount successful" do
    ExBanking.create_user("mune")
    assert ExBanking.deposit("mune", 1, "usd") == {:ok, 1}
  end

  test "withdraw user with wrong arguments" do
    ExBanking.create_user("rut")
    assert ExBanking.withdraw("rut", "1", "usd") == {:error, :wrong_arguments}
    assert ExBanking.withdraw("rut", %{}, "usd") == {:error, :wrong_arguments}
  end

  test "withdraw user does not exist" do
    assert ExBanking.withdraw("erik", 1, "usd") == {:error, :user_does_not_exist}
  end

  test "withdraw not enough money" do
    ExBanking.create_user("jova")
    assert ExBanking.withdraw("jova", 1, "usd") == {:error, :not_enough_money}
  end

  test "withdraw to many requests" do
    ExBanking.create_user("deep")
    {:ok, pid} = User.get_user("deep")
    for _index <- 0..9 do
      send(pid, %{})
    end
    assert ExBanking.withdraw("deep", 1, "usd") == {:error, :too_many_requests_to_user}
  end

  test "get balance wrong arguments" do
    ExBanking.create_user("jose")
    assert ExBanking.get_balance("jose", %{}) == {:error, :wrong_arguments}
    assert ExBanking.get_balance("jose", 1) == {:error, :wrong_arguments}
  end

  test "get balance user does not exist" do
    assert ExBanking.get_balance("unnamed", "usd") == {:error, :user_does_not_exist}
  end

  test "get balance too many requests" do
    ExBanking.create_user("maradona")
    {:ok, pid} = User.get_user("maradona")
    for _index <- 0..9 do
      send(pid, %{})
    end
    assert ExBanking.get_balance("maradona", "usd") == {:error, :too_many_requests_to_user}
  end

  test "send wrong arguments" do
    assert ExBanking.send("luna", "sol", "1", "usd") == {:error, :wrong_arguments}
    assert ExBanking.send("luna", "sol", 1, 1) == {:error, :wrong_arguments}
    assert ExBanking.send("luna", "sol", 1, %{}) == {:error, :wrong_arguments}
  end

  test "send sender does not exists" do
    ExBanking.create_user("ada")
    assert ExBanking.send("rpc", "ada", 1, "usd") == {:error, :sender_does_not_exist}
  end

  test "send receiver does not exists" do
    ExBanking.create_user("luna")
    assert ExBanking.send("luna", "solana", 1, "usd") == {:error, :receiver_does_not_exist}
  end

  test "send too many requests to sender" do
    ExBanking.create_user("stark")
    ExBanking.create_user("michi")
    {:ok, pid} = User.get_user("stark")
    for _index <- 0..9 do
      send(pid, %{})
    end
    assert ExBanking.send("stark", "michi", 1, "usd") == {:error, :too_many_requests_to_sender}
  end

  test "send too many requests to receiver" do
    ExBanking.create_user("susy")
    ExBanking.create_user("tony")
    {:ok, pid} = User.get_user("susy")
    for _index <- 0..9 do
      send(pid, %{})
    end
    assert ExBanking.send("tony", "susy", 1, "usd") == {:error, :too_many_requests_to_receiver}
  end

  test "send balance successful" do
    ExBanking.create_user("rafi")
    ExBanking.create_user("gato")
    ExBanking.deposit("rafi", 10, "btc")
    assert ExBanking.send("rafi", "gato", 2, "btc") == {:ok, 8, 2}
    assert ExBanking.get_balance("rafi", "btc") == {:ok, 8}
    assert ExBanking.get_balance("gato", "btc") == {:ok, 2}
  end
end

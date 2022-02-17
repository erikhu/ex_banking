defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  alias ExBanking

  setup do
    start_supervised!(ExBanking.Supervisor)
    :ok
  end

  test "create user with wrong arguments" do
    assert ExBanking.create_user(0) == {:error, :wrong_arguments}
    assert ExBanking.create_user(%{}) == {:error, :wrong_arguments}
  end

  test "create user that already exists" do
    assert ExBanking.create_user("vitaly") == :ok
    assert ExBanking.create_user("vitaly") == {:error, :user_already_exists}
  end

  test "deposit amount with wrong arguments" do
    ExBanking.create_user("marta")
    assert ExBanking.deposit("marta", -1, "usd") == {:error, :wrong_arguments}
    assert ExBanking.deposit("marta", "1", "usd") == {:error, :wrong_arguments}
  end

  test "deposit amount that user does not exists" do
    assert ExBanking.deposit("juancho", 1, "usd") == {:error, :user_does_not_exists}
  end

  test "deposit amount user too many requests" do
    assert ExBanking.deposit("juancho", 1, "usd") == {:error, :user_does_not_exists}
  end

  test "withdraw user with wrong arguments" do
    ExBanking.create_user("rut")
    for _index <- 0..8 do
      ExBanking.deposit("rut", 1, "usd")
    end
    assert ExBanking.deposit("rut", 1, "usd") == {:error, :too_many_requests_to_user}
  end

  test "withdraw user does not exist" do
    assert ExBanking.withdraw("erik", 1, "usd") == {:error, :user_does_not_exists}
  end

  test "withdraw not enough money" do
    ExBanking.create_user("jova")
    assert ExBanking.withdraw("jova", 1, "usd") == {:error, :not_enough_money}
  end

  test "withdraw to many requests" do
    ExBanking.create_user("jhon")
    ExBanking.deposit("jhon", 15, "usd")
    for _index <- 0..8 do
      ExBanking.withdraw("jhon", 1, "usd")
    end
    assert ExBanking.withdraw("jhon", 1, "usd") == {:error, :too_many_requests_to_user}
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
    ExBanking.create_user("toby")
    for _index <- 0..8 do
      ExBanking.get_balance("toby", "usd")
    end
    assert ExBanking.get_balance("toby", "usd") == {:error, :too_many_requests_to_user}
  end

  test "send wrong arguments" do
    assert ExBanking.send("luna", "sol", "1", "usd") == {:error, :wrong_arguments}
    assert ExBanking.send("luna", "sol", 1, 1) == {:error, :wrong_arguments}
    assert ExBanking.send("luna", "sol", 1, %{}) == {:error, :wrong_arguments}
  end

  test "send sender does not exists" do
    ExBanking.create_user("sol")
    assert ExBanking.send("luna", "sol", 1, "usd") == {:error, :sender_does_not_exist}
  end

  test "send receiver does not exists" do
    ExBanking.create_user("luna")
    assert ExBanking.send("luna", "sol", "1", "usd") == {:error, :receiver_does_not_exists}
  end

  test "send too many requests to sender" do
    ExBanking.create_user("toby")
    ExBanking.create_user("michi")
    for _index <- 0..8 do
      ExBanking.get_balance("toby", "usd")
    end
    assert ExBanking.send("toby", "michi", 1, "usd") == {:error, :too_many_requests_to_sender}
  end

  test "send too many requests to receiver" do
    ExBanking.create_user("susy")
    ExBanking.create_user("tony")
    for _index <- 0..8 do
      ExBanking.get_balance("susy", "usd")
    end
    assert ExBanking.send("tony", "susy", 1, "usd") == {:error, :too_many_requests_to_receiver}
  end
end

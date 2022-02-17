defmodule ExBanking.Application do
  use Application

  #extracted from https://hexdocs.pm/elixir/Application.html
  @impl true
  def start(_type, _args) do
    children = [ExBanking.Supervisor]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

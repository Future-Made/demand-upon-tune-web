defmodule Tune.Spotify.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Registry, keys: :unique, name: Tune.Spotify.SessionRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Tune.Spotify.SessionSupervisor}
      # {Tune.Repo, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def ensure_session(id, credentials) do
    case start_session(id, credentials) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
      error -> error
    end
  end

  defp start_session(id, credentials) do
    DynamicSupervisor.start_child(
      Tune.Spotify.SessionSupervisor,
      {Tune.Spotify.Session.HTTP, {id, credentials}}
    )
  end

  def count_sessions do
    count = DynamicSupervisor.count_children(Tune.Spotify.SessionSupervisor)
    :telemetry.execute([:tune, :session, :count], count)
  end

  def sessions do
    Tune.Spotify.SessionRegistry
    |> Registry.select([{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}])
    |> Enum.map(fn {id, pid} ->
      subscribers_count = Tune.Spotify.Session.HTTP.subscribers_count(id)
      %{id: id, pid: pid, clients_count: subscribers_count}
    end)
  end
end

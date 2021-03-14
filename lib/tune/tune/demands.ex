defmodule Tune.Demands do
  @moduledoc """
  The Tune.Demands context.
  """

  import Ecto.Query, warn: false
  alias Tune.Repo

  alias Tune.Demands.OnlineConcertDemand

  @doc """
  Returns the list of online_concert_demands.

  ## Examples

      iex> list_online_concert_demands()
      [%OnlineConcertDemand{}, ...]

  """
  def list_online_concert_demands(spotify_username) do
    Repo.all(from(demand in OnlineConcertDemand, where: demand.user_id == ^spotify_username,
    order_by: [desc: demand.updated_at]))
  end

  @doc """
  Gets a single online_concert_demand.

  Raises `Ecto.NoResultsError` if the Online concert demand does not exist.

  ## Examples

      iex> get_online_concert_demand!(123)
      %OnlineConcertDemand{}

      iex> get_online_concert_demand!(456)
      ** (Ecto.NoResultsError)

  """
  def get_online_concert_demand!(id), do: Repo.get!(OnlineConcertDemand, id)

  @doc """
  Creates a online_concert_demand.

  ## Examples

      iex> create_online_concert_demand(%{field: value})
      {:ok, %OnlineConcertDemand{}}

      iex> create_online_concert_demand(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_online_concert_demand(attrs \\ %{}) do
    %OnlineConcertDemand{}
    |> OnlineConcertDemand.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a online_concert_demand.

  ## Examples

      iex> update_online_concert_demand(online_concert_demand, %{field: new_value})
      {:ok, %OnlineConcertDemand{}}

      iex> update_online_concert_demand(online_concert_demand, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_online_concert_demand(%OnlineConcertDemand{} = online_concert_demand, attrs) do
    online_concert_demand
    |> OnlineConcertDemand.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a online_concert_demand.

  ## Examples

      iex> delete_online_concert_demand(online_concert_demand)
      {:ok, %OnlineConcertDemand{}}

      iex> delete_online_concert_demand(online_concert_demand)
      {:error, %Ecto.Changeset{}}

  """
  def delete_online_concert_demand(%OnlineConcertDemand{} = online_concert_demand) do
    Repo.delete(online_concert_demand)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking online_concert_demand changes.

  ## Examples

      iex> change_online_concert_demand(online_concert_demand)
      %Ecto.Changeset{data: %OnlineConcertDemand{}}

  """
  def change_online_concert_demand(%OnlineConcertDemand{} = online_concert_demand, attrs \\ %{}) do
    OnlineConcertDemand.changeset(online_concert_demand, attrs)
  end
end
